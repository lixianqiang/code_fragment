#include "config_builder.h"
#include "config_manager.h"
#include "config_utils.h"
#include <fstream>
#include <gtest/gtest.h>
#include <iostream>
#include <map>
#include <memory>
#include <rapidjson/document.h>
#include <rapidjson/istreamwrapper.h>
#include <rapidjson/prettywriter.h>
#include <rapidjson/rapidjson.h>
#include <rapidjson/stringbuffer.h>
#include <sstream>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <sys/stat.h>
#include <utility>
#include <vector>

using namespace std;
using namespace rapidjson;

TEST(function, SplitFilePath) {
  string file_path = "/home/lxq/rapidjson/home.json";
  std::pair<string, string> file_name = SplitFilePath(file_path);
  auto rte = file_name.first + "/" + file_name.second;
  EXPECT_EQ(file_name.first, "/home/lxq/rapidjson");
  EXPECT_EQ(file_name.second, "home.json");
}

TEST(function, Create) {
  string file_path = "/home/lxq/rapidjson/cdfges.json";
  std::pair<string, string> file_name = SplitFilePath(file_path);
  bool rst = Create(file_path);
  EXPECT_TRUE(rst);
}

TEST(class, save) {
  ConcentrateConfig concentrate_config;
  concentrate_config.stringObject = "111originObject";
  concentrate_config.boolObject = true;
  concentrate_config.intObject = 6616;
  concentrate_config.doubleObject = 7717.777;
  concentrate_config.int_list.push_back(1);
  concentrate_config.int_list.push_back(1);
  concentrate_config.int_list.push_back(1);
  concentrate_config.bool_list.push_back(true);
  concentrate_config.bool_list.push_back(false);
  concentrate_config.bool_list.push_back(true);
  concentrate_config.doule_list.push_back(21.01);
  concentrate_config.doule_list.push_back(21.01);
  concentrate_config.doule_list.push_back(21.01);
  concentrate_config.string_list.push_back("jj");
  concentrate_config.string_list.push_back("jj");
  concentrate_config.string_list.push_back("jj");

  Document document(kObjectType);
  ConcentrateConfigBuilder().build(concentrate_config, document);
  string file_path = "/home/lxq/rapidjson/wahaha.json";
  Write(file_path, document);
}

TEST(class, write) {
  string file_path = "/home/lxq/rapidjson/wahaha.json";
  Document document(rapidjson::kObjectType);
  Read(file_path, document);
  ConcentrateConfig tf_concentrate_config;
  ConcentrateConfigBuilder().build(document, tf_concentrate_config);
}

TEST(class, manager) {
  string file_path = "/home/lxq/rapidjson/wahaha.json";
  ConcentrateConfigBuilder cbuilder;
  Document document(rapidjson::kObjectType);
  Read(file_path, document);
  ConcentrateConfig tf_concentrate_config1;
  config_manager[file_path] = &cbuilder;
  config_manager[file_path]->build(document, tf_concentrate_config1);
}

TEST(class, manager2) {
  string file_path;
  ConfigManager config_manager;
  ConcentrateConfigBuilder cbuilder;
  file_path = "/home/lxq/rapidjson/wahaha.json";
  config_manager.table[file_path] = &cbuilder;
  // read
  ConcentrateConfig param;
  config_manager.LoadFile(file_path, param);
  // write
  config_manager.SaveFile(file_path, param);
}

int main() {
  ::testing::InitGoogleTest();
  return RUN_ALL_TESTS();
}
