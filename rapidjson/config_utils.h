#ifndef _H_CONFIG_UTILS_H_
#define _H_CONFIG_UTILS_H_

#include <cstdio>
#include <fstream>
#include <rapidjson/document.h>
#include <rapidjson/istreamwrapper.h>
#include <rapidjson/prettywriter.h>
#include <rapidjson/stringbuffer.h>
#include <sstream>
#include <sys/stat.h>
#include <utility>

using rapidjson::Document;
using rapidjson::PrettyWriter;
using rapidjson::StringBuffer;
using std::ifstream;
using std::ofstream;
using std::string;

inline bool IsFileExist(const string &file) {
  struct stat st;
  bool rst = stat(file.c_str(), &st) == 0 ? true : false;
  return rst;
}

// 将file_path拆分为文件名和路径
inline std::pair<string, string> SplitFilePath(const string &file_path) {
  string::size_type pos = file_path.find_last_of('/');
  string folder_path = file_path.substr(0, pos);
  string file_name = file_path.substr(pos + 1);
  return std::make_pair(folder_path, file_name);
}

// 根据file_path递归创建文件
inline bool Create(const string &file_path) {
  string folder_path;
  string::size_type pos = 0;
  while ((pos = file_path.find_first_of("/", pos)) != string::npos) {
    folder_path = file_path.substr(0, pos);
    if (!folder_path.empty() && !IsFileExist(folder_path)) {
      if (mkdir(folder_path.c_str(), S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH) ==
          -1) {
        return false;
      }
    }
    pos++;
  }
  ofstream outfile(file_path);
  outfile.close();
  return true;
}

inline bool Write(const string &file_path, const string &content) {
  if (!IsFileExist(file_path) && !Create(file_path))
    return false;
  ofstream outfile(file_path);
  outfile << content;
  outfile.close();
  return true;
}

inline bool Write(const string &file_path, const Document &content) {
  if (!IsFileExist(file_path) && !Create(file_path))
    return false;
  StringBuffer buffer;
  PrettyWriter<StringBuffer> writer(buffer);
  content.Accept(writer);
  ofstream outfile(file_path);
  outfile << buffer.GetString();
  outfile.close();
  return true;
}

inline bool Read(const string &file_path, string &content) {
  if (!IsFileExist(file_path))
    return false;
  ifstream infile(file_path);
  std::stringstream buffer;
  buffer << infile.rdbuf();
  content = buffer.str();
  infile.close();
  return true;
}

inline bool Read(const string &file_path, Document &content) {
  if (!IsFileExist(file_path))
    return false;
  ifstream infile(file_path);
  rapidjson::IStreamWrapper isw(infile);
  content.ParseStream(isw);
  if (content.HasParseError())
    return false;
  return true;
}

#endif // _H_CONFIG_UTILS_H_