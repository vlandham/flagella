namespace :create do
  
  def check_for_migration migration_name
    current_migration_names = Dir.glob(File.join(MIGRATIONS_DIR, "*.rb")).map {|file| file =~ /\d+_(.*)\.rb$/; $1}
    abort "ERROR: #{migration_name} is already a migration name. Please choose another name" if current_migration_names.include? migration_name
  end
  
  class String
    def camelize
      self.split("_").inject("") {|total,str| total << str.capitalize }
    end
  end
    
  class MigrationTemplate
    attr_accessor :name, :table, :fields
    
    def initialize name, table, fields
      @table = table ? table.to_sym : nil
      @name = name
      @fields = fields ? unmangle_fields(fields) : []
    end
    
    def path
      prefix = DateTime.now.strftime("%Y%m%d%H%M%S")
      File.join(MIGRATIONS_DIR, prefix+"_"+@name+".rb")
    end
        
    def unmangle_fields mangled_field
      fields = mangled_field.split(".")
      fields.inject({}) do |hash, item| 
        items = item.split(":") 
        if items.size != 2
          abort "ERROR: need to separate table name and type with : \n Problem input: #{item}"
        end
        hash[items[0]] = items[1].to_sym
        hash
      end
    end
    
    def up_to_s
      up_string = "\tdef self.up\n"
      up_string << "\t\t#create_table :#{@table}\n" if @table
      @fields.each do |field, type|
        up_string << "\t\tadd_column :#{@table}, :#{field}, :#{type}\n"
      end
      up_string << "\tend\n"
      up_string
    end
    
    def down_to_s
      down_string = "\tdef self.down\n"
      down_string << "\t\t#drop_table :#{@table}\n" if @table
      @fields.each do |field, type|
        down_string << "\t\tremove_column :#{@table}, :#{field}, :#{type}\n"
      end      
      down_string << "\tend\n"
    end
    
    def to_file      
      File.open(self.path, "w") do |file|
        file << "class #{@name.camelize} < ActiveRecord::Migration" << "\n"
        file << up_to_s
        file << "\n"
        file << down_to_s
        file << "end" << "\n"
      end
    end 
  end
  
  class ModelTemplate
    attr_accessor :name
    
    def initialize name
      @name = name
    end
    
    def path
      File.join(MODELS_DIR,@name+".rb")
    end
    
    def to_file
      File.open(self.path, "w") do |file|
        file << "class #{@name.camelize} < ActiveRecord::Base\n"
        file << "\n"
        file << "end"
      end
    end
  end
  
  desc 'Create a new migration in db/migrate. First parameter is name of new migration.'
  task :migration, :name, :table, :fields do |t, args|
    check_for_migration args[:name]
    migration = MigrationTemplate.new(args[:name], args[:table], args[:fields])
    migration.to_file
  end
  
  desc 'Create a new model in models and associated migration in db/migrate. First parameter is name of new model.'
  task :model, :name, :fields do |t, args|    
    table_name = "#{args[:name]}s"
    migration_name = "create_#{table_name}"
    check_for_migration migration_name
    
    model = ModelTemplate.new(args[:name])
    model.to_file
    
    migration = MigrationTemplate.new(migration_name, table_name, args[:fields])
    migration.to_file
  end
  
end