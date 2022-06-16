// **************************************************************************
// Model for handling locally stored plants managed by this app
// **************************************************************************
// MIT License
// Copyright © 2022 Patrick Fial
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
// is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// **************************************************************************
// includes
// **************************************************************************

#pragma once

#include <QImage>
#include <QString>
#include <QVariant>
#include <QDateTime>
#include <QDir>

// **************************************************************************
// namespace plants
// **************************************************************************

namespace plants
{
   // **************************************************************************
   // struct Plant
   // **************************************************************************

   struct Plant
   {
      QString id;
      QString species;
      QString commonNames;
      double score;
      QVariantList images;
      QDateTime added;
      QImage thumbnail;

      explicit operator QVariant() const
      {
         QVariantMap m;
         m.insert("id", id);
         m.insert("species", species);
         m.insert("commonNames", commonNames);
         m.insert("score", score);
         m.insert("images", images);
         m.insert("added", added);
         return m;
      }
   };

   struct PlantResult
   {
         Plant* plant;
         QString err;
   };

   // **************************************************************************
   // class Plants
   // **************************************************************************

   class Plants
   {
      public:
         void setStorageDir(QDir dir);

         PlantResult openPlant(QString filePath);
         PlantResult createPlant(QVariantMap& identificationResult);

      protected:
         PlantResult _openPlant(QByteArray jsonData);

         QDir storageDir;
   };

} // namespace plants
