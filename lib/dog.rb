class Dog

    attr_accessor :name, :breed, :id

    def initialize(name: name, breed: breed,id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = 'CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);'

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = 'DROP TABLE dogs;'

        DB[:conn].execute(sql)
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
    
    def save
        if self.id
          self.update
        else
        
        sql = 'INSERT INTO dogs (name, breed) VALUES (?,?);'
        
        DB[:conn].execute(sql, self.name, self.breed)
        
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end    
        self
    end

    def self.create(hash)
        new_dog = self.new(hash)
        new_dog.save
        new_dog
    end

    def self.new_from_db(row)
        new_dog = self.new(name: row[1],breed: row[2])
        new_dog.id = row[0]
        new_dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
 
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = 'SELECT * FROM dogs WHERE name = ? AND breed = ?'
        dog = DB[:conn].execute(sql, name, breed)
        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
        else 
            dog = Dog.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1;
    SQL
 
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
    end

end