#include "config_builder.h"

bool ConcentrateConfigBuilder::build(const IConfig &iconfig,
                                     rapidjson::Document &document) {
  const ConcentrateConfig &config =
      dynamic_cast<const ConcentrateConfig &>(iconfig);
  auto &allocator = document.GetAllocator();
  Save(document, "intObject", config.intObject, Int, allocator);
  Save(document, "boolObject", config.boolObject, Bool, allocator);
  Save(document, "doubleObject", config.doubleObject, Double, allocator);
  Save(document, "stringObject", config.stringObject, String, allocator);
  SaveArray(document, "int_list", config.int_list, Int, allocator);
  SaveArray(document, "bool_list", config.bool_list, Bool, allocator);
  SaveArray(document, "dou_list", config.doule_list, Double, allocator);
  SaveArray(document, "str_list", config.string_list, String, allocator);
  return true;
}

bool ConcentrateConfigBuilder::build(const rapidjson::Document &document,
                                     IConfig &iconfig) {
  ConcentrateConfig &config = dynamic_cast<ConcentrateConfig &>(iconfig);
  Load(document, "stringObject", config.stringObject, String);
  Load(document, "boolObject", config.boolObject, Bool);
  Load(document, "intObject", config.intObject, Int);
  Load(document, "boolObject", config.boolObject, Bool);
  Load(document, "doubleObject", config.doubleObject, Double);
  LoadArray(document, "int_list", config.int_list, Int);
  LoadArray(document, "str_list", config.string_list, String);
  LoadArray(document, "bool_list", config.bool_list, Bool);
  LoadArray(document, "dou_list", config.doule_list, Double);
  return true;
}