#include <QGuiApplication>
#include <QCoreApplication>
#include <QUrl>
#include <QString>
#include <QQuickView>

#include "src/plantsimageprovider.hpp"
#include "src/plantsmodel.hpp"

int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationName("plants.s710");
    QCoreApplication::setApplicationName("plants.s710");

    QGuiApplication *app = new QGuiApplication(argc, (char**)argv);
    app->setApplicationName("plants.s710");

    qmlRegisterType<plants::PlantsModel>("PlantsModel", 1, 0, "PlantsModel");

    QQuickView *view = new QQuickView();
    QQmlEngine *engine = view->engine();
    engine->addImageProvider(QLatin1String("plants"), new plants::PlantsImageProvider());

    view->setSource(QUrl("qrc:/Main.qml"));
    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->show();

    return app->exec();
}
