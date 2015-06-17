# require 'C:\Program Files\OpenStudio 1.6.0\Ruby\openstudio.rb'

require 'openstudio'
require 'openstudio/ruleset/ShowRunnerOutput'
# require "#{File.dirname(__FILE__)}/../measure.rb"
require './script/create_DOE_prototype_building/measure.rb'
# require 'test/unit'
require 'minitest/autorun'
# class CreateDOEPrototypeBuilding_Test < Test::Unit::TestCase
class CreateDOEPrototypeBuilding_Test < Minitest::Test
def test_CreateDOEPrototypeBuilding_a
# create an instance of the measure
measure = CreateDOEPrototypeBuilding.new
# create an instance of a runner
runner = OpenStudio::Ruleset::OSRunner.new
# Make an empty model
model = OpenStudio::Model::Model.new
# get arguments and test that they are what we are expecting
arguments = measure.arguments(model)
argument_map = OpenStudio::Ruleset.convertOSArgumentVectorToMap(arguments)
# Data Preprocessing
gui_selection_building_type = 'Small Office'
gui_selection_weather = 'Athens'
gui_selection_vintage = 'Post 1980'
building_vin = {}
building_vin["Pre 1980"] = "DOE Ref Pre-1980"
building_vin["Post 1980"] = "DOE Ref 1980-2004"
building_vin["New Construction"] = "90.1-2010"
building_typ = {}
building_typ["Small Office"] = "SmallOffice"
building_typ["Secondary School"] = "SecondarySchool"
building_typ["Small Hotel"] = "SmallHotel"
building_climate = {}
building_climate["Albany-Dougherty County"] = "ASHRAE 169-2006-3B"
building_climate["Alma-Bacon County"] = "ASHRAE 169-2006-3B"
building_climate["Athens-Ben Epps"] = "ASHRAE 169-2006-3B"
building_climate["Athens"] = "ASHRAE 169-2006-3B"
building_climate["Atlanta-Hartsfield-Jackson Intl"] = "ASHRAE 169-2006-3B"
building_climate["Augusta-Bush-Field"] = "ASHRAE 169-2006-3B"
building_climate["Brunswick-Golden Isles"] = "ASHRAE 169-2006-3B"
building_climate["Brunswick-Malcolm McKinnon"] = "ASHRAE 169-2006-2A"
building_climate["Columbus Metro"] = "ASHRAE 169-2006-3B"
building_climate["Dekalb Peachtree"] = "ASHRAE 169-2006-3B"
building_climate["Fort Benning-Lawson Field"] = "ASHRAE 169-2006-3B"
building_climate["Fulton County"] = "ASHRAE 169-2006-3B"
building_climate["Macon-Middle Georgia Rgnl"] = "ASHRAE 169-2006-3B"
building_climate["Marietta-Dobbins"] = "ASHRAE 169-2006-4A"
building_climate["Rome-Richard B Russell"] = "ASHRAE 169-2006-3B"
building_climate["Savannah-Hunter"] = "ASHRAE 169-2006-3B"
building_climate["Savannah Intl"] = "ASHRAE 169-2006-2A"
building_climate["Valdosta-Moody"] = "ASHRAE 169-2006-3B"
building_climate["Valdosta Rgnl"] = "ASHRAE 169-2006-2A"
building_climate["Warner Robins"] = "ASHRAE 169-2006-3B"
# create hash of argument values
args_hash = {}
args_hash["building_type"] = building_typ[gui_selection_building_type]
args_hash["building_vintage"] = building_vin[gui_selection_vintage]
args_hash["climate_zone"] = building_climate[gui_selection_weather]
# populate argument with specified hash value if specified
arguments.each do |arg|
temp_arg_var = arg.clone
if args_hash[arg.name]
assert(temp_arg_var.setValue(args_hash[arg.name]))
end
argument_map[arg.name] = temp_arg_var
end
# Run the measure
measure.run(model, runner, argument_map)
#save the model
output_file_path = OpenStudio::Path.new(File.dirname(__FILE__) + "/NewModel.osm")
model.save(output_file_path,true)
result = runner.result    
# Show log messages   
show_output(result)
assert_equal("Success", result.value.valueName)
#save the model
output_file_path = OpenStudio::Path.new(File.dirname(__FILE__) + "/NewModel.osm")
model.save(output_file_path,true)
end
end
