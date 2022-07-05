// **************************************************************************
// Model for handling locally stored plants managed by this app
// **************************************************************************
// MIT License
// Copyright © 2022 Patrick Fial
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
// associated documentation files (the “Software”), to deal in the Software without planttriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions: The above copyright notice and this
// permission notice shall be included in all copies or substantial portions of the Software. THE
// SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
// LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// **************************************************************************
// includes
// **************************************************************************

#include "plant.hpp"

#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QUuid>

namespace C
{
#include <libintl.h>
}

// **************************************************************************
// namespace plants
// **************************************************************************

namespace plants
{
void Plants::setStorageDir(QDir dir)
{
   storageDir = dir;
}

// **************************************************************************
// openPlant
// **************************************************************************

PlantResult Plants::createPlant(QVariantMap& identificationResult)
{
   QVariantList newImages;
   QString plantID = QUuid::createUuid().toString().replace("{", "").replace("}", "");
   identificationResult["id"] = plantID;

   if (!identificationResult.contains("sourceImages") || !identificationResult.contains("images"))
      return PlantResult{nullptr, C::gettext("No source images in identification result")};

   int i = 0;
   auto sourceImages = identificationResult["sourceImages"].toList();

   for (QVariant& imageUrl : sourceImages)
   {
      QFile sourceFile(imageUrl.toString());
      QFileInfo info(imageUrl.toString());
      QString suffix = info.suffix();
      QString targetPath = storageDir.filePath(QString("%1_%2.").arg(plantID).arg(i++) + suffix);

      QVariantMap imageMap;
      imageMap["url"] = targetPath;
      imageMap["copyright"] = C::gettext("Own photo");
      imageMap["ownPhoto"] = true;

      newImages << imageMap;

      if (!sourceFile.copy(targetPath))
         return PlantResult{nullptr, C::gettext("Failed to save source images for plant: ")
                                       + sourceFile.errorString()};
   }

   for (QVariant& image : identificationResult["images"].toList())
   {
      QVariantMap dict = image.toMap();
      dict["ownPhoto"] = false;
      newImages << dict;
   }

   identificationResult["images"] = newImages;
   identificationResult["added"] = QDateTime::currentDateTime().toString(Qt::ISODate);

   QByteArray jsonData
     = QJsonDocument::fromVariant(identificationResult).toJson(QJsonDocument::Compact);
   QString jsonTargetPath = storageDir.filePath(QString("%1.json").arg(plantID));
   QFile jsonFile(jsonTargetPath);

   if (!jsonFile.open(QIODevice::WriteOnly))
      return PlantResult{nullptr,
                         C::gettext("Failed to save plant JSON: ") + jsonFile.errorString()};

   if (!jsonFile.write(jsonData))
      return PlantResult{nullptr,
                         C::gettext("Failed to save plant JSON: ") + jsonFile.errorString()};

   jsonFile.close();

   return _openPlant(jsonData);
}

// **************************************************************************
// openPlant
// **************************************************************************

PlantResult Plants::openPlant(QString filePath)
{
   QFile jsonFile(filePath);
   QByteArray jsonData;

   if (!jsonFile.open(QIODevice::ReadOnly))
      return PlantResult{nullptr,
                         C::gettext("Failed to open plant JSON: ") + jsonFile.errorString()};

   jsonData = jsonFile.readAll();

   if (jsonData.isEmpty() || jsonFile.errorString() != "Unknown error")
      return PlantResult{nullptr,
                         C::gettext("Failed to open plant JSON #2: ") + jsonFile.errorString()};

   jsonFile.close();

   return _openPlant(jsonData);
}

// **************************************************************************
// openPlant
// **************************************************************************

PlantResult Plants::_openPlant(QByteArray jsonData)
{
   QJsonParseError err;
   QJsonDocument doc = QJsonDocument::fromJson(jsonData, &err);

   if (err.error != QJsonParseError::NoError)
      return PlantResult{nullptr, C::gettext("Failed to read plant JSON: ") + err.errorString()};

   auto parsed = (!doc.isNull() && doc.isObject()) ? doc.object() : QJsonObject();

   if (parsed.isEmpty())
      return PlantResult{nullptr, C::gettext("Unexpected/malformed plant JSON #1")};

   if (!parsed.contains("id") || !parsed.contains("commonNames") || !parsed.contains("images")
       || !parsed.contains("score") || !parsed.contains("sourceImages")
       || !parsed.contains("species"))
   {
      return PlantResult{nullptr, C::gettext("Unexpected/malformed plant JSON #2")};
   }

   auto plant = new Plant();
   QVariantList images;
   QString firstImage;

   plant->id = parsed["id"].toString();
   plant->species = parsed["species"].toString();
   plant->commonNames = parsed["commonNames"].toString();
   plant->score = parsed["score"].toDouble();

   foreach (auto image, parsed["images"].toArray())
   {
      QVariantMap currentImage;

      auto dict = image.toObject();

      if (!dict.contains("url") || !dict.contains("copyright") || !dict.contains("ownPhoto"))
         return PlantResult{nullptr, C::gettext("Unexpected/malformed plant JSON #3")};

      currentImage["url"] = dict["url"].toString();
      currentImage["copyright"] = dict["copyright"].toString();
      currentImage["ownPhoto"] = dict["ownPhoto"].toBool();

      if (firstImage.isEmpty())
         firstImage = dict["url"].toString();

      images << currentImage;
   }

   if (!firstImage.isEmpty())
   {
      QFile thumbFile(firstImage);
      QByteArray imageData;

      if (!thumbFile.open(QIODevice::ReadOnly))
         return PlantResult{nullptr,
                            C::gettext("Failed to open plant image: ") + thumbFile.errorString()};

      imageData = thumbFile.readAll();

      if (imageData.isEmpty() || thumbFile.errorString() != "Unknown error")
         return PlantResult{nullptr,
                            C::gettext("Failed to open plant image: ") + thumbFile.errorString()};

      thumbFile.close();

      plant->thumbnail = QImage::fromData(imageData);
   }

   plant->images = images;
   plant->added = QDateTime::fromString(parsed["added"].toString(), Qt::ISODate);

   return PlantResult{plant, ""};
}
} // namespace plants
