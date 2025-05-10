import csv
import os

DATA_FILES = {
    "products": "products.csv",
    "customers": "customers.csv",
    "orders": "orders.csv"
}

# Завантаження таблиці

def load_table(name):
    path = DATA_FILES.get(name)
    if not path or not os.path.exists(path):
        print("Файл не знайдено.")
        return [], []
    with open(path, newline='', encoding='utf-8') as f:
        reader = csv.reader(f)
        rows = list(reader)
        header, data = rows[0], rows[1:]
        return header, data

# Збереження таблиці

def save_table(name, header, data):
    path = DATA_FILES.get(name)
    with open(path, mode="w", newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(data)

# Друк таблиці

def print_table(header, data):
    print(" | ".join(header))
    for row in data:
        print(" | ".join(row))

# Головне меню

def main():
    while True:
        print("\n=== GlobeXMonitors Database Simulator ===")
        print("1. Переглянути таблицю")
        print("2. Додати запис")
        print("3. Видалити запис за ID")
        print("4. Пошук за першою літерою")
        print("5. Пошук за номером (ID)")
        print("0. Вийти")

        choice = input("Оберіть опцію: ")

        if choice == "0":
            break

        table = input("Введіть назву таблиці (products/customers/orders): ").strip()
        header, data = load_table(table)
        if not header:
            continue

        if choice == "1":
            print_table(header, data)

        elif choice == "2":
            new_row = [input(f"{col}: ") for col in header]
            data.append(new_row)
            save_table(table, header, data)
            print("Запис додано.")

        elif choice == "3":
            id_to_delete = input("Введіть ID запису для видалення: ")
            data = [row for row in data if row[0] != id_to_delete]
            save_table(table, header, data)
            print("Запис видалено, якщо був знайдений.")

        elif choice == "4":
            letter = input("Введіть першу літеру для пошуку по другому стовпцю: ").lower()
            filtered = [row for row in data if row[1].lower().startswith(letter)]
            print_table(header, filtered)

        elif choice == "5":
            number = input("Введіть ID для пошуку: ")
            result = [row for row in data if row[0] == number]
            print_table(header, result)

        else:
            print("Невірна опція.")

if __name__ == "__main__":
    main()
