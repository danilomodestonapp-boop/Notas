from pathlib import Path

def fix_file(path: Path):
    if not path.exists():
        print(f"SKIP: {path} (not found)")
        return
    b = path.read_bytes()
    # Try UTF-8 first
    try:
        text = b.decode('utf-8')
        utf_ok = True
    except Exception:
        utf_ok = False

    if not utf_ok:
        # Try windows-1252 (cp1252)
        try:
            text = b.decode('cp1252')
            print(f"Read {path} as cp1252")
        except Exception as e:
            print(f"ERROR reading {path}: {e}")
            return

    # If text contains typical mojibake patterns like 'Ã', try to fix double-encoding
    if 'Ã' in text:
        try:
            fixed = text.encode('cp1252').decode('utf-8')
            path.write_bytes(b"\xef\xbb\xbf" + fixed.encode('utf-8'))
            print(f"FIXED (double-encoded): {path}")
            return
        except Exception as e:
            print(f"FAILED to fix double-encoding for {path}: {e}")

    # Ensure file is saved with UTF-8 BOM
    if not b.startswith(b"\xef\xbb\xbf"):
        try:
            path.write_bytes(b"\xef\xbb\xbf" + text.encode('utf-8'))
            print(f"ADDED BOM/rewrote as UTF-8: {path}")
        except Exception as e:
            print(f"FAILED to write {path}: {e}")
    else:
        print(f"OK: {path} (already has BOM)")


if __name__ == '__main__':
    base = Path(__file__).parent.parent
    targets = [
        base / 'resumo-tarefas-2026-06-15.md',
        base / 'tarefas-concluidas.md',
    ]
    for t in targets:
        fix_file(t)
