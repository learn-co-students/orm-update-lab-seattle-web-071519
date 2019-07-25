require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  @@all = []

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
    @@all << self
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end

  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
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

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.all
    sql = <<-SQL
      SELECT * FROM students
    SQL
    rows = DB[:conn].execute(sql)
    instances = rows.map do |row|
      student = Student.new(row[0], row[1], row[2])
    end
    instances
  end

  def self.new_from_db(row)
    student = Student.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    self.all.find do |student|
      student.name == name
    end
  end

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]


end
