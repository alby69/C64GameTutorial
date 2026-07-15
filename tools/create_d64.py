#!/usr/bin/env python3
"""create_d64.py — Genera immagini disco .D64 per Commodore 64

Crea un'immagine disco D64 (1541) da uno o piu file .prg.

Utilizzo come script:
  python tools/create_d64.py -o game.d64 game.prg main.prg data.prg
  python tools/create_d64.py -o game.d64 --name "MY GAME" --type PRG,SEQ,USR game.prg main.prg data.prg

Utilizzo come modulo:
  from tools.create_d64 import create_d64_image
  create_d64_image(["game.prg", "main.prg"], "game.d64")

Formato D64:
  - 35 tracce, 683 settori totali
  - Tracce 1-17:   21 settori ciascuna
  - Tracce 18-24:  19 settori ciascuna
  - Tracce 25-30:  18 settori ciascuna
  - Tracce 31-35:  17 settori ciascuna
  - Settore = 256 byte
  - Directory su traccia 18, settore 0 (BAM) + 1+
  - BAM: Track 18, Sector 0 (Block Availability Map)
  - Ogni entry directory: 32 byte (max 8 per settore)
"""

import struct
import sys
import os
import argparse

# ─────────────────────────────────────────────────────
# Costanti formato D64
# ─────────────────────────────────────────────────────

SECTOR_SIZE = 256

# Numero di settori per traccia (tracce 1-based)
TRACK_SECTORS = (
    [21] * 17  # tracce 1-17
    + [19] * 7  # tracce 18-24
    + [18] * 6  # tracce 25-30
    + [17] * 5  # tracce 31-35
)

TOTAL_TRACKS = 35
TOTAL_SECTORS = sum(TRACK_SECTORS)  # 683

# Offsets in byte per ogni traccia (1-based index)
TRACK_OFFSET = [0]
for i in range(TOTAL_TRACKS):
    TRACK_OFFSET.append(TRACK_OFFSET[-1] + TRACK_SECTORS[i])

# Directory track
DIR_TRACK = 18
DIR_SECTOR_BAM = 0

# Tipi di file
FILE_TYPES = {
    "PRG": 0x82,
    "SEQ": 0x81,
    "USR": 0x83,
    "DEL": 0x00,
}

FILE_TYPE_NAMES = {v: k for k, v in FILE_TYPES.items()}

# DOS version marker
DOS_TYPE = "A"

# ─────────────────────────────────────────────────────
# Strutture dati D64
# ─────────────────────────────────────────────────────


class D64Image:
    """Rappresenta un'immagine disco D64."""

    def __init__(self, disk_name="COMMODORE 64", dos_type="A"):
        self.disk_name = disk_name.upper()[:16]
        self.dos_type = dos_type
        # Allocazione buffer: 683 settori * 256 byte
        self.sectors = bytearray(TOTAL_SECTORS * SECTOR_SIZE)

        # BAM: traccia 18, settore 0
        # Inizializza BAM — tutti i settori liberi
        self.bam = bytearray(SECTOR_SIZE)
        self._init_bam()

        # Directory entries (max ~144 per 1541)
        self.dir_entries = []

    def _init_bam(self):
        """Inizializza la BAM con tutti i settori liberi."""
        # Byte 0: prossimo settore directory (18,1)
        self.bam[0] = DIR_TRACK
        self.bam[1] = 1  # prossimo settore

        # Byte 2: DOS version
        self.bam[2] = 0x41  # 'A'

        # Byte 3-4: riservati
        self.bam[3] = 0x00
        self.bam[4] = 0x00

        # Byte 5-251: BAM (4 bytes per traccia)
        # Ogni traccia: 3 byte bitmap + 1 byte "sectors free"
        for t in range(TOTAL_TRACKS):
            track_num = t + 1
            sectors_in_track = TRACK_SECTORS[t]
            base = 5 + t * 4

            # Tutti i settori liberi
            bits_free = (1 << sectors_in_track) - 1

            # Byte basso: primi 8 settori
            self.bam[base] = bits_free & 0xFF
            # Byte centrale: settori 8-15
            self.bam[base + 1] = (bits_free >> 8) & 0xFF
            # Byte alto: settori 16+ (per tracce con >16 settori)
            self.bam[base + 2] = (bits_free >> 16) & 0xFF
            # Contatore settori liberi
            self.bam[base + 3] = sectors_in_track

    def _sector_offset(self, track, sector):
        """Calcola l'offset in byte per un dato settore (1-based track)."""
        if track < 1 or track > TOTAL_TRACKS:
            raise ValueError(f"Traccia fuori range: {track}")
        if sector < 0 or sector >= TRACK_SECTORS[track - 1]:
            raise ValueError(f"Settore fuori range: {sector} per traccia {track}")
        return TRACK_OFFSET[track - 1] * SECTOR_SIZE + sector * SECTOR_SIZE

    def _bam_free(self, track, sector):
        """Controlla se un settore e libero nella BAM."""
        base = 5 + (track - 1) * 4
        bit = 1 << (sector % 8)
        byte_idx = base + (sector // 8)
        return bool(self.bam[byte_idx] & bit)

    def _bam_allocate(self, track, sector):
        """Alloca un settore nella BAM."""
        base = 5 + (track - 1) * 4
        byte_idx = base + (sector // 8)
        bit = 1 << (sector % 8)
        if not (self.bam[byte_idx] & bit):
            raise RuntimeError(f"Settore {track},{sector} gia allocato")
        self.bam[byte_idx] &= ~bit
        self.bam[base + 3] -= 1

    def _bam_free_count(self, track):
        """Restituisce il numero di settori liberi in una traccia."""
        return self.bam[5 + (track - 1) * 4 + 3]

    def _find_free_sector(self, prefer_track=None):
        """Trova un settore libero. Se prefer_track, prova prima quella."""
        if prefer_track is not None and 1 <= prefer_track <= TOTAL_TRACKS:
            if self._bam_free_count(prefer_track) > 0:
                for s in range(TRACK_SECTORS[prefer_track - 1]):
                    if self._bam_free(prefer_track, s):
                        return prefer_track, s

        # Cerca dalla traccia 1
        for t in range(1, TOTAL_TRACKS + 1):
            if t == DIR_TRACK:
                continue  # salta traccia directory
            if self._bam_free_count(t) > 0:
                for s in range(TRACK_SECTORS[t - 1]):
                    if self._bam_free(t, s):
                        return t, s
        raise RuntimeError("Disco pieno: nessun settore libero")

    def allocate_sector(self, track=None):
        """Alloca e restituisce un nuovo settore libero."""
        t, s = self._find_free_sector(prefer_track=track)
        self._bam_allocate(t, s)
        return t, s

    def write_sector(self, track, sector, data):
        """Scrive dati in un settore (max 256 byte)."""
        offset = self._sector_offset(track, sector)
        self.sectors[offset : offset + len(data)] = data[:SECTOR_SIZE]

    def read_sector(self, track, sector):
        """Legge i dati di un settore."""
        offset = self._sector_offset(track, sector)
        return bytes(self.sectors[offset : offset + SECTOR_SIZE])

    def save_bam(self):
        """Salva la BAM sul disco (track 18, sector 0)."""
        self.write_sector(DIR_TRACK, DIR_SECTOR_BAM, self.bam)

    def add_file(self, filepath, filename=None, file_type="PRG"):
        """Aggiunge un file .prg alla directory.

        Args:
            filepath: percorso del file sorgente
            filename: nome del file su disco (max 16 char, default: nome senza ext)
            file_type: "PRG", "SEQ", "USR" o "DEL"
        """
        if not os.path.exists(filepath):
            raise FileNotFoundError(f"File non trovato: {filepath}")

        if filename is None:
            filename = os.path.splitext(os.path.basename(filepath))[0]
        filename = filename.upper()[:16]

        ftype = FILE_TYPES.get(file_type.upper())
        if ftype is None:
            raise ValueError(f"Tipo file sconosciuto: {file_type}")

        # Leggi contenuto file
        with open(filepath, "rb") as f:
            data = f.read()

        if len(data) == 0:
            raise ValueError(f"File vuoto: {filepath}")

        # PRG ha 2 byte header (load address)
        if file_type.upper() == "PRG" and len(data) >= 2:
            load_addr = struct.unpack("<H", data[0:2])[0]
            file_data = data[2:]
        else:
            load_addr = 0x0801
            file_data = data

        # Calcola numero di blocchi (arrotonda su)
        blocks = (len(file_data) + SECTOR_SIZE - 1) // SECTOR_SIZE
        if blocks == 0:
            blocks = 1

        # Alloca settori per i dati
        data_track, data_sector = self.allocate_sector()

        # Scrivi il primo blocco dati
        first_chunk = file_data[:SECTOR_SIZE]
        self.write_sector(data_track, data_sector, first_chunk)

        # Se i dati eccedono un settore, alloca catena
        current_track = data_track
        current_sector = data_sector
        offset = SECTOR_SIZE

        while offset < len(file_data):
            next_track, next_sector = self.allocate_sector()
            chunk = file_data[offset : offset + SECTOR_SIZE]
            self.write_sector(next_track, next_sector, chunk)

            # Scrivi puntatore al prossimo settore nel settore corrente
            pos = self._sector_offset(current_track, current_sector)
            self.sectors[pos] = next_track
            self.sectors[pos + 1] = next_sector

            current_track = next_track
            current_sector = next_sector
            offset += SECTOR_SIZE

        # Imposta fine catena nel ultimo settore
        pos = self._sector_offset(current_track, current_sector)
        self.sectors[pos] = 0x00
        self.sectors[pos + 1] = 0xFF

        # Aggiungi entry directory
        self.dir_entries.append(
            {
                "filename": filename,
                "file_type": ftype,
                "track": data_track,
                "sector": data_sector,
                "blocks": blocks,
                "load_addr": load_addr,
                "size": len(file_data),
            }
        )

        return {
            "filename": filename,
            "track": data_track,
            "sector": data_sector,
            "blocks": blocks,
            "size": len(file_data),
        }

    def build_directory(self):
        """Costruisce i settori della directory con tutti gli entry."""
        # La directory occupa traccia 18, iniziando da settore 1
        # Ogni settore tiene 8 entry da 32 byte
        # + 2 byte puntatore al prossimo settore directory

        entries = self.dir_entries
        num_sectors_needed = (len(entries) + 7) // 8

        dir_sectors = []
        for i in range(num_sectors_needed):
            t, s = self.allocate_sector()
            dir_sectors.append((t, s))

        # Imposta catena settori directory
        for i, (t, s) in enumerate(dir_sectors):
            if i == 0:
                # BAM pointer: primo settore dir
                self.bam[0] = t
                self.bam[1] = s
            if i < len(dir_sectors) - 1:
                next_t, next_s = dir_sectors[i + 1]
                next_t_ptr = next_t
                next_s_ptr = next_s
            else:
                next_t_ptr = 0x00
                next_s_ptr = 0xFF  # fine

            # Costruisci settore directory
            dir_data = bytearray(SECTOR_SIZE)
            dir_data[0] = next_t_ptr
            dir_data[1] = next_s_ptr

            # Entry in questo settore
            start = i * 8
            end = min(start + 8, len(entries))
            for j in range(start, end):
                entry = entries[j]
                pos = 2 + (j - start) * 32
                self._pack_dir_entry(dir_data, pos, entry)

            self.write_sector(t, s, dir_data)

        # Se nessun file, imposta primo settore directory vuoto
        if not entries:
            # Trova un settore libero per la directory vuota
            t, s = self.allocate_sector()
            self.bam[0] = t
            self.bam[1] = s
            dir_data = bytearray(SECTOR_SIZE)
            dir_data[0] = 0x00
            dir_data[1] = 0xFF
            self.write_sector(t, s, dir_data)

    def _pack_dir_entry(self, buf, pos, entry):
        """Pacchetta un entry directory nel buffer."""
        # Byte 0: track del primo settore dati
        buf[pos] = entry["track"]
        # Byte 1: settore del primo settore dati
        buf[pos + 1] = entry["sector"]
        # Byte 2: tipo file (con bit 7 = tipo, bit 6 = locked)
        buf[pos + 2] = entry["file_type"]
        # Byte 3-4: fine catena (settore successivo)
        buf[pos + 3] = 0x00
        buf[pos + 4] = 0xFF
        # Byte 5-16: nome file (padding con $A0)
        name = entry["filename"].ljust(16, chr(0xA0))
        buf[pos + 5 : pos + 5 + 16] = name.encode("ascii", errors="replace")
        # Byte 17-18: tipo (sid)
        buf[pos + 17] = 0x00
        buf[pos + 18] = 0x80
        # Byte 19-20: numero blocchi usati (little-endian)
        buf[pos + 19] = entry["blocks"] & 0xFF
        buf[pos + 20] = (entry["blocks"] >> 8) & 0xFF
        # Byte 21-31: riservati (zero)
        for k in range(21, 32):
            buf[pos + k] = 0x00

    def save_disk_image(self, output_path):
        """Salva l'immagine disco D64 su file."""
        self.build_directory()
        self.save_bam()

        with open(output_path, "wb") as f:
            f.write(bytes(self.sectors))

        return output_path

    def info(self):
        """Restituisce informazioni sul disco."""
        free_sectors = 0
        for t in range(1, TOTAL_TRACKS + 1):
            if t != DIR_TRACK:
                free_sectors += self._bam_free_count(t)

        used_sectors = TOTAL_SECTORS - free_sectors - 1  # -1 per BAM
        return {
            "tracks": TOTAL_TRACKS,
            "total_sectors": TOTAL_SECTORS,
            "free_sectors": free_sectors,
            "used_sectors": used_sectors,
            "files": len(self.dir_entries),
            "disk_name": self.disk_name,
            "dos_type": self.dos_type,
        }


# ─────────────────────────────────────────────────────
# Funzione principale (API pubblica)
# ─────────────────────────────────────────────────────


def create_d64_image(files, output, disk_name="COMMODORE 64", file_types=None):
    """Crea un'immagine D64 da una lista di file.

    Args:
        files: lista di percorsi file. Puo essere:
               - lista di stringhe: ["file1.prg", "file2.prg"]
               - lista di tuple: [("file1.prg", "NOME1", "PRG"), ("file2.prg", "NOME2", "SEQ")]
        output: percorso del file .d64 di output
        disk_name: nome del disco (max 16 char)
        file_types: lista di tipi file parallela a files (opzionale se in tuple)

    Returns:
        dict con informazioni sul disco creato
    """
    d64 = D64Image(disk_name=disk_name)

    for i, f in enumerate(files):
        if isinstance(f, str):
            # Solo percorso — deduci nome e tipo
            fname = None
            ftype = None
            if file_types and i < len(file_types):
                ftype = file_types[i]
            elif f.lower().endswith(".seq"):
                ftype = "SEQ"
            elif f.lower().endswith(".usr"):
                ftype = "USR"
            else:
                ftype = "PRG"
            d64.add_file(f, filename=fname, file_type=ftype)
        elif isinstance(f, tuple):
            # (percorso, nome, tipo) o (percorso, nome) o (percorso,)
            filepath = f[0]
            fname = f[1] if len(f) > 1 else None
            ftype = f[2] if len(f) > 2 else "PRG"
            d64.add_file(filepath, filename=fname, file_type=ftype)
        else:
            raise TypeError(f"Tipo entry non valido: {type(f)}")

    d64.save_disk_image(output)
    return d64.info()


# ─────────────────────────────────────────────────────
# CLI
# ─────────────────────────────────────────────────────


def parse_type_list(types_str):
    """Parse una stringa di tipi separata da virgola."""
    if not types_str:
        return None
    return [t.strip().upper() for t in types_str.split(",")]


def main():
    parser = argparse.ArgumentParser(
        description="Crea immagini disco .D64 per Commodore 64",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Esempi:
  %(prog)s -o game.d64 game.prg main.prg data.prg
  %(prog)s -o game.d64 --name "MY GAME" game.prg
  %(prog)s -o data.d64 --type SEQ,USR --name "DATA DISK" sprites.seq music.usr
  %(prog)s -o game.d64 --type PRG game.prg --type PRG main.prg --type SEQ high.seq
        """,
    )
    parser.add_argument(
        "-o",
        "--output",
        required=True,
        help="File output .d64",
    )
    parser.add_argument(
        "--name",
        default="COMMODORE 64",
        help="Nome del disco (max 16 caratteri)",
    )
    parser.add_argument(
        "--type",
        default=None,
        help="Tipi file separati da virgola (PRG, SEQ, USR, DEL)",
    )
    parser.add_argument(
        "files",
        nargs="+",
        help="File .prg da includere nel disco",
    )

    args = parser.parse_args()

    file_types = parse_type_list(args.type)

    # Se --type ha meno valori di files, riempi con PRG
    if file_types and len(file_types) < len(args.files):
        file_types.extend(["PRG"] * (len(args.files) - len(file_types)))

    try:
        info = create_d64_image(
            files=args.files,
            output=args.output,
            disk_name=args.name,
            file_types=file_types,
        )
        print(f"Disco creato: {args.output}")
        print(f"  Nome disco: {info['disk_name']}")
        print(f"  File: {info['files']}")
        print(f"  Settori usati: {info['used_sectors']}/{info['total_sectors']}")
        print(f"  Settori liberi: {info['free_sectors']}")
        print(f"  Tracce: {info['tracks']}")
    except Exception as e:
        print(f"Errore: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
