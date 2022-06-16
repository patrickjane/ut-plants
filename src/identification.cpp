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

#include "identification.hpp"

#include <QFile>
#include <QDebug>
#include <QHttpMultiPart>
#include <QUrlQuery>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QLocale>
#include <QSettings>

#include <variant>

#define API_MAX_RESULTS 5
#define API_URL "https://my-api.plantnet.org/v2/identify/all"
#define LANGUAGES_URL "https://my-api.plantnet.org/v2/languages"
// #define API_URL "http://10.0.60.43:3000/identify"
// #define LANGUAGES_URL "http://10.0.60.43:3000/languages"

namespace C {
#include <libintl.h>
}

namespace plants
{
   // **************************************************************************
   // class Identification
   // **************************************************************************

   Identification::Identification(network::Network* network, QObject* parent)
      : net(network), QObject(parent), url(API_URL)
   {
      QSettings settings;

      if (settings.contains("apiKey"))
         query.addQueryItem("api-key", settings.value("apiKey").toString());

      query.addQueryItem("include-related-images", "true");
      url.setQuery(query);
   }

   // **************************************************************************
   // identifyPlant
   // **************************************************************************

   void Identification::initLanguages()
   {
      QSettings settings;
      QUrlQuery q;

      if (!settings.contains("apiKey"))
      {
         qDebug() << "No API key available, skip languages load";
         return;
      }

      q.addQueryItem("api-key", settings.value("apiKey").toString());

      QUrl languagesUrl(LANGUAGES_URL);
      languagesUrl.setQuery(q);

      net->get<network::ReqCallback>(languagesUrl, headers, [this](int err, int code, QByteArray body)
      {
         QSettings settings;

         if (err != QNetworkReply::NoError || code != 200 || body.isEmpty())
         {
            qDebug() << "FAIL Languages response: " << QString::number(code) << " (" << body << ")";

            QString lang("en");

            if (settings.contains("language"))
               lang = settings.value("language").toString();

            query.addQueryItem("lang", lang);
            url.setQuery(query);
            return;
         }

         QString systemLang = QLocale::system().name().split('_').at(0);

         auto doc = QJsonDocument::fromJson(body);
         auto parsed = (!doc.isNull() && doc.isArray()) ? doc.array() : QJsonArray();

         QStringList languages;

         foreach (auto lang, parsed)
            languages << lang.toString();

         if (languages.contains(systemLang))
         {
            query.addQueryItem("lang", systemLang);
            url.setQuery(query);
            settings.setValue("language", systemLang);
         }
         else
         {
            query.addQueryItem("lang", "en");
            url.setQuery(query);
            settings.setValue("language", "en");
         }
      });
   }

   // **************************************************************************
   // setApiKey
   // **************************************************************************

   void Identification::setApiKey(QString key)
   {
      query.removeQueryItem("api-key");
      query.addQueryItem("api-key", key);
      url.setQuery(query);
   }

   // **************************************************************************
   // identifyPlant
   // **************************************************************************

   void Identification::identifyPlant(QVariantList& request)
   {
      QString err;
      QVariantList sourceImages;
      QHttpMultiPart* multiPart = createMultipart(request, sourceImages, err);

      if (multiPart == nullptr)
      {
         emit identificationResult(QString(err), QVariantList());
         return;
      }

      net->postMultipart<network::ReqCallback>(url, multiPart, headers, [this, multiPart, sourceImages](int err, int code, QByteArray body)
      {
         QVariantList resultPayload;
         delete multiPart;

         qDebug() << "Identify response: " << QString::number(code);

         if (err != QNetworkReply::NoError || code != 200 || body.isEmpty())
         {
            qDebug() << "Identify response: " << QString::number(code) << " (" << body << ")";
            emit identificationResult(QString(C::gettext("Failed to process identification (%1/%2)")).arg(err).arg(code), resultPayload);
            return;
         }

         auto doc = QJsonDocument::fromJson(body);
         auto parsed = (!doc.isNull() && doc.isObject()) ? doc.object() : QJsonObject();

         if (parsed.isEmpty() || !parsed.contains("results"))
         {
            emit identificationResult(QString(C::gettext("Unexpected/malformed response received")), resultPayload);
            return;
         }

         foreach (auto result, parsed["results"].toArray())
         {
            if (resultPayload.size() >= API_MAX_RESULTS)
               break;

            QVariantMap currentResult;
            QVariantList currentImages;
            auto dict = result.toObject();

            if (!dict.contains("score")
                || !dict.contains("species")
                || !dict.contains("images"))
            {
               emit identificationResult(QString(C::gettext("skipping invalid result #1")), resultPayload);
               continue;
            }

            currentResult["score"] = dict["score"].toDouble();

            auto species = dict["species"].toObject();

            if (!species.contains("scientificName") || !species.contains("commonNames"))
            {
               emit identificationResult(QString(C::gettext("skipping invalid result #2")), resultPayload);
               continue;
            }

            currentResult["species"] = species["scientificName"].toString();

            QStringList commonNames;

            foreach (auto commonName, species["commonNames"].toArray())
            {
               commonNames << commonName.toString();
            }

            currentResult["commonNames"] = commonNames.join(", ");

            foreach (auto image, dict["images"].toArray())
            {
               QVariantMap currentImage;

               auto dict = image.toObject();

               if (!dict.contains("url") || !dict.contains("citation") || !dict["url"].toObject().contains("m"))
               {
                  emit identificationResult(QString(C::gettext("skipping invalid image #1")), resultPayload);
                  continue;
               }

               currentImage["url"] = dict["url"].toObject()["m"].toString();
               currentImage["copyright"] = dict["citation"].toString();

               currentImages << currentImage;
            }

            currentResult["images"] = currentImages;
            currentResult["sourceImages"] = sourceImages;
            resultPayload << currentResult;
         }

         emit identificationResult("", resultPayload);
      });
   }

   // **************************************************************************
   // createMultipart
   // **************************************************************************

   QHttpMultiPart* Identification::createMultipart(QVariantList& request, QVariantList& sourceUrls, QString& err)
   {
      QHttpMultiPart* multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

      if (!request.size())
      {
         err = "No images contained in request";
         return nullptr;
      }

      for (QVariant& imageInfo : request)
      {
         QVariantMap map = imageInfo.toMap();

         if (!map.contains("url") || !map.contains("organ"))
         {
            err = "Invalid image info with missing url/type";
            return nullptr;
         }

         QString url = map["url"].toString();
         QString organ = map["organ"].toString();

         sourceUrls << url;

         QHttpPart textPart;
         textPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"organs\""));
         textPart.setBody(organ.toUtf8());
         multiPart->append(textPart);

         QHttpPart imagePart;
         imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"images\"; filename=\"image_1.jpeg\""));
         imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("image/jpeg"));

         QFile *file = new QFile(url);
         file->setParent(multiPart); // we cannot delete the file now, so delete it with the multiPart
         file->open(QIODevice::ReadOnly);

         imagePart.setBodyDevice(file);
         multiPart->append(imagePart);
      }

      return multiPart;
   }
}