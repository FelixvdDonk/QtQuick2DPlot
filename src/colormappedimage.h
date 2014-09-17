#ifndef COLORMAPPEDIMAGE_H
#define COLORMAPPEDIMAGE_H

#include "dataclient.h"

class ColormappedImage : public DataClient
{
    Q_OBJECT
    Q_PROPERTY(double minimumValue MEMBER m_min_value WRITE setMinimumValue NOTIFY minimumValueChanged)
    Q_PROPERTY(double maximumValue MEMBER m_max_value WRITE setMaximumValue NOTIFY maximumValueChanged)
    Q_PROPERTY(QString colormap MEMBER m_colormap WRITE setColormap NOTIFY colormapChanged)

public:
    explicit ColormappedImage(QQuickItem *parent = 0);
    ~ColormappedImage();

    void setMinimumValue(double value);
    void setMaximumValue(double value);
    void setColormap(const QString& colormap);

signals:
    void minimumValueChanged(double value);
    void maximumValueChanged(double value);
    void colormapChanged(const QString& colormap);

protected:
    virtual QSGNode* updatePaintNode(QSGNode *, UpdatePaintNodeData *);

private:
    double m_min_value;
    double m_max_value;
    QString m_colormap;
    bool m_new_colormap;
    QSGTexture* m_texture_cmap;
};


#endif // COLORMAPPEDIMAGE_H

