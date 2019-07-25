require_relative "../config/environment.rb"
require ('pry')
class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name=nil,grade=nil,id = nil)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create(name,grade)
    creation = Student.new(name,grade)
    # creation.name = name
    # creation.grade = grade
    creation.save
    return creation
  end

  def self.new_from_db(row)
      student = Student.new(row[1],row[2],row[0])
      return student
  end

  def save
    sql = <<-SQL
      SELECT id FROM students WHERE id = ?
    SQL
    result = DB[:conn].execute(sql,@id)
    if result == []
      save_new
    else
      update
    end
  end

  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ?  WHERE id = ?
    SQL
    result = DB[:conn].execute(sql,@name,@grade,@id)
  end

  def save_new
    sql = <<-SQL
    INSERT INTO students(name,grade) VALUES (?,?)
    SQL
    DB[:conn].execute(sql,@name,@grade)
    sql = <<-SQL
      SELECT id FROM students ORDER BY id DESC LIMIT 1
      SQL
      @id = DB[:conn].execute(sql)[0][0]
      
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS students;
    SQL
    DB[:conn].execute(sql)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM students
    WHERE name = ?
    SQL
    thing = DB[:conn].execute(sql,name)[0]
    Student.new_from_db(thing)
  end
end

# binding.pry