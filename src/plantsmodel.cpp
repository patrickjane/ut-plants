// **************************************************************************
// Model for handling locally stored plants managed by this app
// **************************************************************************
// MIT License
// Copyright © 2022 Patrick Fial
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
// associated documentation files (the “Software”), to deal in the Software without restriction,
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

#include "plantsmodel.hpp"

#include <QDebug>
#include <QStandardPaths>
#include <QUuid>

namespace C
{
#include <libintl.h>
}

namespace plants
{
// **************************************************************************
// class PlantsModel
// **************************************************************************

PlantsModel* PlantsModel::instance = nullptr;

PlantsModel::PlantsModel(QObject* parent)
  : QAbstractListModel(parent),
    storageReady(false),
    identificator(&net, this)
{
   instance = this;

   connect(&identificator, &Identification::identificationResult, this,
           &PlantsModel::identificationResult);
}

// **************************************************************************
// init
// **************************************************************************

QString PlantsModel::init()
{
   QString dataPath = getDataPath();

   if (!dataPath.size())
      return C::gettext("Failed to determine writable app data storage location");

   QDir dir(dataPath + "/plants");

   if (!dir.exists())
   {
      bool res = dir.mkpath(dataPath + "/plants");

      if (!res)
         return QString(C::gettext("App data storage location inaccessible")) + " ("
                + QString(C::gettext("can't create subfolder:")) + " " + dir.absolutePath() + ")";
   }

   plantsDir.setPath(dir.path());
   plantsDir.setSorting(QDir::Time);
   storageReady = true;

   plants.setStorageDir(plantsDir);

   qDebug() << "DATA DIR: " << dir;

   identificator.initLanguages();
   return "";
}

// **************************************************************************
// data
// **************************************************************************

QVariant PlantsModel::data(const QModelIndex& index, int role) const
{
   if (role == Qt::DisplayRole || role == PlantRole)
      return static_cast<QVariant>(*(mItems[index.row()]));

   return QVariant();
}

// **************************************************************************
// rowCount
// **************************************************************************

int PlantsModel::rowCount(const QModelIndex& /*parent*/) const
{
   return mItems.size();
}

// **************************************************************************
// roleNames
// **************************************************************************

QHash<int, QByteArray> PlantsModel::roleNames() const
{
   QHash<int, QByteArray> roles;
   roles[PlantRole] = "plant";
   return roles;
}

// **************************************************************************
// getDataPath
// **************************************************************************

QString PlantsModel::getDataPath() const
{
   return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
}

// **************************************************************************
// reload
// **************************************************************************

void PlantsModel::reload()
{
   if (!storageReady || !plantsDir.path().size())
   {
      qDebug() << "Storage directory not initialized";
      return;
   }

   beginResetModel();

   for (auto p : mItems)
      delete p;

   mItems.clear();
   mItemMap.clear();

   for (const QFileInfo& info : plantsDir.entryInfoList(QDir::Files | QDir::NoSymLinks
                                                        | QDir::NoDotAndDotDot | QDir::Readable))
   {
      if (info.fileName().startsWith(".") || !info.fileName().endsWith(".json"))
         continue;

      auto plantResult = plants.openPlant(info.canonicalFilePath());

      if (!plantResult.err.isEmpty())
      {
         qDebug() << "Plant open failed: " << plantResult.err;
      }
      else
      {
         mItemMap[plantResult.plant->id] = plantResult.plant;
         mItems.push_back(plantResult.plant);
      }
   }

   std::sort(mItems.begin(), mItems.end(), plantSorter);

   endResetModel();
   emit countChanged();
}

// **************************************************************************
// saveIdentification
// **************************************************************************

QString PlantsModel::savePlant(QVariantMap identificationResult)
{
   auto plantResult = plants.createPlant(identificationResult);

   if (!plantResult.err.isEmpty())
      return plantResult.err;

   if (!plantResult.plant)
      return C::gettext("Failed to save plant");

   beginResetModel();

   mItemMap[plantResult.plant->id] = plantResult.plant;
   mItems.push_back(plantResult.plant);

   std::sort(mItems.begin(), mItems.end(), plantSorter);

   endResetModel();
   emit countChanged();
   return "";
}

// **************************************************************************
// deletePlant
// **************************************************************************

QString PlantsModel::deletePlant(QString id)
{
   auto it = std::find_if(mItems.begin(), mItems.end(),
                          [&id](Plant* plant) { return plant->id == id; });

   if (it == mItems.end() || !mItemMap.count((*it)->id))
      return C::gettext("Failed to delete plant (plant unknown)");

   auto plant = *it;
   QFile plantFile(plantsDir.filePath(QString("%1.json").arg(id)));

   if (!plantFile.exists())
      return C::gettext("Failed to delete plant (plant unknown)");

   bool res = plantFile.remove();

   if (!res)
      return QString(C::gettext("Failed to delete plant from storage directory (%1)"))
        .arg(plantFile.errorString());

   for (QVariant& image : plant->images)
   {
      QVariantMap dict = image.toMap();
      QFile imageFile(dict["url"].toString());

      if (!dict["ownPhoto"].toBool())
         continue;

      if (!imageFile.exists())
         return C::gettext("Failed to delete plant (plant unknown)");

      bool res = imageFile.remove();

      if (!res)
         return QString(C::gettext("Failed to delete plant image from storage directory (%1)"))
           .arg(imageFile.errorString());
   }

   beginResetModel();

   mItemMap.erase(plant->id);
   mItems.erase(it);
   delete plant;

   endResetModel();
   emit countChanged();

   return "";
}

// **************************************************************************
// identifyPlant
// **************************************************************************

void PlantsModel::identifyPlant(QVariantList request)
{
   identificator.identifyPlant(request);
}

} // namespace plants
