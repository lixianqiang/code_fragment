
#ifndef _H_CONFIG_MANAGER_H_
#define _H_CONFIG_MANAGER_H_

#include "config_builder.h"
#include "config_struct.h"
#include "config_utils.h"

class ConfigManager
{
public:
  void LoadFile(const string& file_path, IConfig& iconfig)
  {
    if (!HasFilePath(file_path))
    {
      return;
    }
    document_.SetObject();
    Read(file_path, document_);
    table[file_path]->build(document_, iconfig);
  }

  void SaveFile(const string& file_path, IConfig& iconfig)
  {
    if (!HasFilePath(file_path))
    {
      return;
    }
    document_.SetObject();
    table[file_path]->build(iconfig, document_);
    Write(file_path, document_);
  }

public:
  std::map<std::string, IConfigBuilder*> table;

private:
  bool HasFilePath(const string& file_path)
  {
    return table.find(file_path) != table.end();
  }

private:
  rapidjson::Document document_;
  // test
};

#endif