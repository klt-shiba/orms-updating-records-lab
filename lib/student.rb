require_relative "../config/environment.rb"

class Student


  attr_accessor :id, :name, :grade
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(id=nil, name, grade)
    self.id = id
    self.name = name
    self.grade = grade
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(*args)
    student = Student.new(*args)
    student.save
    student
  end


  def self.new_from_db(row)

    id = row[0]
    name = row[1]
    grade = row[2]

    student = Student.new(id, name, grade)
    student
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.find_by_name(name)
    #Stores the SQL query across multiple lines
    sql = <<-SQL
    SELECT * 
    FROM students
    WHERE name = ?
    LIMIT 1
    SQL
    # Executes the data base query
    # Iteates thgrough the array and creates a new instance
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS students
    SQL

    DB[:conn].execute(sql)
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
