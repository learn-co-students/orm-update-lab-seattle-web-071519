require_relative "../config/environment.rb"

 # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

class Student

  attr_accessor :grade, :name
  attr_reader :id

  def initialize(id = nil, name, grade)
    @id = id
    @name = name 
    @grade = grade
  end 
    ### C ###
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
    id INTEGER PRIMARY KEY, 
    name TEXT, 
    grade TEXT
    )
    SQL
    DB[:conn].execute(sql)
    end 

    ### D ###
    def self.drop_table
      sql = "DROP TABLE students"
      DB[:conn].execute(sql)
    end 

    ### U ###
    def update 
      sql = "UPDATE students SET id = ?, name = ? WHERE grade = ?"
      DB[:conn].execute(sql, self.id, self.name, self.grade)
    end  

    def save
      if self.id
        self.update
      else
      sql = "INSERT INTO students (id, name, grade)
      VALUES (?, ?, ?)"
  
      DB[:conn].execute(sql, @id, @name, @grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
      end
    end 

    ## Example shows (name:, album:) ?? ##

    def self.create(name, grade)
      student = Student.new(name, grade)
      student.save
      student
      # DB[:conn].execute(sql, @name, @grade)
    end
  
    def self.new_from_db(row)
      id = row[0]
      name = row[1]
      grade = row[2]
      self.new(id, name, grade)
      # new_student = self.new
      # new_student.id = row[0]
      # new_student.name = row[1]
      # new_student.grade = row[2]
      # new_student
    end 
    
    def self.all
      sql = <<-SQL
      SELECT * FROM students 
      SQL
      DB[:conn].execute(sql).map do |row|
        Student.new_from_db(row)
      end 
    end 

    def self.find_by_name(name)
      sql = "SELECT * FROM students WHERE name = ?"
      result = DB[:conn].execute(sql, name)[0]
      Student.new(result[0], result[1], result[2])
    end 
  
end
