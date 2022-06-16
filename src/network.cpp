// **************************************************************************
// Network stack helper functions
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

#include "network.hpp"

// **************************************************************************
// namespace network
// **************************************************************************

namespace network
{
   // **************************************************************************
   // ctor/dtor
   // **************************************************************************

   Network::Network(QObject* parent)
      : QObject(parent), manager(parent)
   {
   }

   // **************************************************************************
   // finish
   // **************************************************************************

   void Network::finish(QNetworkReply* reply, ReqDetailCallback cb)
   {
      auto onFinished = [reply, cb, this]()
      {
         int httpCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
         auto httpReason = reply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toString();

         if (reply->error() != QNetworkReply::NoError)
            emit networkError(reply->error(), reply->errorString());

         network::ReqHeaders headers;

         foreach(const auto& header, reply->rawHeaderPairs())
            headers[QString::fromUtf8(header.first)] = QString::fromUtf8(header.second);

         cb(static_cast<int>(reply->error()),
            httpCode,
            reply->readAll(),
            headers);
      };

      connect(reply, &QNetworkReply::finished, this, onFinished);
   }

   // **************************************************************************
   // finish
   // **************************************************************************

   void Network::finish(QNetworkReply* reply, ReqCallback cb)
   {
      auto onFinished = [reply, cb, this]()
      {
         int httpCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
         auto httpReason = reply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toString();

         if (reply->error() != QNetworkReply::NoError)
            emit networkError(reply->error(), reply->errorString());

         cb(static_cast<int>(reply->error()), httpCode, reply->readAll());
      };

      connect(reply, &QNetworkReply::finished, this, onFinished);
   }

   // **************************************************************************
   // toJson
   // **************************************************************************

   QByteArray ReqBody::toJsonString() const
   {
      QJsonObject payload;

      for(auto param : toStdMap())
      {
         if (param.second.toString() == "true")
            payload[param.first] = QJsonValue(true);
         else if (param.second.toString() == "false")
            payload[param.first] = QJsonValue(false);
         else
            payload[param.first] = QJsonValue(param.second.toString());
      }

      return QJsonDocument(payload).toJson();
   }
}
