import sqlite3

# Connect to database
conn = sqlite3.connect('example.db')
cursor = conn.cursor()

# Drop existing tables and triggers for clean start
cursor.execute('DROP TABLE IF EXISTS table_two')
cursor.execute('DROP TABLE IF EXISTS table_one')
cursor.execute('DROP TRIGGER IF EXISTS sync_to_table_two')

# Create first table
cursor.execute('''
CREATE TABLE table_one (
    shared_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    email TEXT
)
''')

# Create second table with the same shared_id column
cursor.execute('''
CREATE TABLE table_two (
    shared_id INTEGER PRIMARY KEY,
    address TEXT,
    phone TEXT,
    FOREIGN KEY (shared_id) REFERENCES table_one(shared_id)
)
''')

# Create trigger to automatically insert row in table_two when inserting into table_one
cursor.execute('''
CREATE TRIGGER sync_to_table_two
AFTER INSERT ON table_one
BEGIN
    INSERT INTO table_two (shared_id, address, phone)
    VALUES (NEW.shared_id, NULL, NULL);
END
''')

conn.commit()

# Insert into table_one only - table_two gets the shared_id automatically!
print("\nInserting rows into TABLE ONE only...")
cursor.execute("INSERT INTO table_one (name, email) VALUES (?, ?)", 
               ('Alice', 'alice@example.com'))
cursor.execute("INSERT INTO table_one (name, email) VALUES (?, ?)", 
               ('Bob', 'bob@example.com'))
cursor.execute("INSERT INTO table_one (name, email) VALUES (?, ?)", 
               ('Charlie', 'charlie@example.com'))

conn.commit()

# Now you can update table_two independently if needed
print("\n" + "=" * 70)
print("Now updating TABLE TWO with additional data...")
print("-" * 70)
cursor.execute("UPDATE table_two SET address = ?, phone = ? WHERE shared_id = ?", 
               ('123 Main St', '555-0001', 1))
cursor.execute("UPDATE table_two SET address = ?, phone = ? WHERE shared_id = ?", 
               ('456 Oak Ave', '555-0002', 2))

conn.commit()

conn.close()
print("\n✓ Complete! The shared_id column is automatically synchronized.")