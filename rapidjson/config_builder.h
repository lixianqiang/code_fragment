#ifndef _H_CONFIG_BUILDER_H_
#define _H_CONFIG_BUILDER_H_
#include "config_struct.h"
#include "rapidjson/document.h"
#include "rapidjson/prettywriter.h"
#include "rapidjson/stringbuffer.h"
#include <map>
#include <string>

#define JsonInt(Val, Allocator) rapidjson::Value(Val)
#define JsonBool(Val, Allocator) rapidjson::Value(Val)
#define JsonDouble(Val, Allocator) rapidjson::Value(Val)
#define JsonString(Val, Allocator)                                             \
  rapidjson::Value(Val.c_str(), Val.size(), Allocator)

#define Save(Dict, Key, Val, Type, Allocator)                                  \
  if (Dict.IsObject())                                                         \
  Dict.AddMember(Key, Json##Type(Val, Allocator), Allocator)

#define SaveArray(Dict, Key, Val, Type, Allocator)                             \
  if (Dict.IsObject() && Val.size() != 0) {                                    \
    rapidjson::Value array(rapidjson::kArrayType);                             \
    for (size_t i = 0; i < Val.size(); i++) {                                  \
      array.PushBack(Json##Type(Val[i], Allocator), Allocator);                \
    }                                                                          \
    Dict.AddMember(Key, array, Allocator);                                     \
  }

#define Load(Dict, Key, Val, Type)                                             \
  if (Dict.HasMember(Key) && Dict[Key].Is##Type())                             \
  Val = Dict[Key].Get##Type()

#define LoadArray(Dict, Key, Val, Type)                                        \
  if (Dict.HasMember(Key) && Dict[Key].IsArray()) {                            \
    Val.resize(Dict[Key].Size());                                              \
    for (size_t i = 0; i < Dict[Key].Size(); i++)                              \
      Val[i] = Dict[Key][i].Get##Type();                                       \
  }

class IConfigBuilder {
public:
  virtual bool build(const IConfig &iconfig, rapidjson::Document &document) = 0;
  virtual bool build(const rapidjson::Document &document, IConfig &iconfig) = 0;
};
class ConcentrateConfigBuilder : public IConfigBuilder {
public:
  ConcentrateConfigBuilder() {}
  virtual bool build(const IConfig &iconfig, rapidjson::Document &document);
  virtual bool build(const rapidjson::Document &document, IConfig &iconfig);
};

static std::map<std::string, IConfigBuilder *> config_manager;
#endif // _H_CONFIG_BUILDER_H_