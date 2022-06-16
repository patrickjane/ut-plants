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

#pragma once

#include <QString>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <functional>
#include <QHttpMultiPart>

#include <QJsonObject>
#include <QJsonDocument>

#include <QDebug>

// **************************************************************************
// namespace network
// **************************************************************************

namespace network
{
   // **************************************************************************
   // definitions
   // **************************************************************************

   using ReqHeaders = QMap<QString,QString>;
   using ReqDetailCallback = std::function<void(int, int, QByteArray, ReqHeaders)>;
   using ReqCallback = std::function<void(int, int, QByteArray)>;

   // **************************************************************************
   // struct ReqBody
   // **************************************************************************

   struct ReqBody : public QMap<QString,QVariant>
   {
         QByteArray toJsonString() const;
   };

   // **************************************************************************
   // class Network
   // **************************************************************************

   class Network : public QObject
   {
         Q_OBJECT

      public:
         Network(QObject* parent = nullptr);

         template <typename C>
         void get(QUrl url, ReqHeaders headers, C cb)
         {
            QNetworkRequest req(url);

            for(auto header : headers.toStdMap())
               req.setRawHeader(header.first.toUtf8(), header.second.toUtf8());

            finish(manager.get(req), cb);
         }

         template <typename C>
         void postJson(QUrl url, const ReqBody& body, ReqHeaders headers, C cb)
         {
            QNetworkRequest req(url);
            req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

            for(auto header : headers.toStdMap())
               req.setRawHeader(header.first.toUtf8(), header.second.toUtf8());

            finish(manager.post(req, body.toJsonString()), cb);
         }

         template <typename C>
         void postMultipart(QUrl url, QHttpMultiPart* multiPart, ReqHeaders headers, C cb)
         {
            QNetworkRequest req(url);

            for(auto header : headers.toStdMap())
               req.setRawHeader(header.first.toUtf8(), header.second.toUtf8());

            finish(manager.post(req, multiPart), cb);
         }

         template <typename C>
         void putJson(QUrl url, const ReqBody& body, ReqHeaders headers, C cb)
         {
            QNetworkRequest req(url);
            req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

            for(auto header : headers.toStdMap())
               req.setRawHeader(header.first.toUtf8(), header.second.toUtf8());

            finish(manager.put(req, body.toJsonString()), cb);
         }

      signals:
         void networkError(int, QString);

      private:
         void finish(QNetworkReply* reply, ReqCallback cb);
         void finish(QNetworkReply* reply, ReqDetailCallback cb);

         QNetworkAccessManager manager;
   };
}
