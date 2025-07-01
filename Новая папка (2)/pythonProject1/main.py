# main.py
import tkinter as tk
from tkinter import messagebox
from database import Database

def run_app():
    # Создаем окно
    root = tk.Tk()
    root.title("Checklist App")

    # Пример кнопки для выполнения какого-то действия
    def on_button_click():
        messagebox.showinfo("Info", "Button clicked!")

    button = tk.Button(root, text="Click Me", command=on_button_click)
    button.pack()
    # Запускаем главный цикл
    root.mainloop()


if __name__ == "__main__":
    run_app()