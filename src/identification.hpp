// **************************************************************************
// Class for HTTP API interaction of my.plantnet.org
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

#include "network.hpp"

#include <QString>
#include <QVariant>
#include <QUrlQuery>
#include <QUrl>

// **************************************************************************
// namespace plants
// **************************************************************************

namespace plants
{
   // **************************************************************************
   // struct Plant
   // **************************************************************************

   class Identification : public QObject
   {
      Q_OBJECT

      public:
         Identification(network::Network* net, QObject* parent = nullptr);

         void initLanguages();
         void setApiKey(QString key);

         void identifyPlant(QVariantList& request);

      signals:
         void identificationResult(QString error, QVariantList result);

      protected:
         QHttpMultiPart* createMultipart(QVariantList& request, QVariantList& sourceImages, QString& err);

         QUrlQuery query;
         QUrl url;
         network::ReqHeaders headers;
         network::Network* net;
   };

} // namespace plants