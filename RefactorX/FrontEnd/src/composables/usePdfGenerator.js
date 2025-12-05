import jsPDF from 'jspdf'
import 'jspdf-autotable'

export function usePdfGenerator() {
  const generarPDFMulta = (documento) => {
    try {
      if (!documento) {
        throw new Error('No se proporcionó información del documento')
      }

      console.log('Generando PDF para documento:', documento)

      const doc = new jsPDF({
        orientation: 'portrait',
        unit: 'mm',
        format: 'letter'
      })

      const pageWidth = doc.internal.pageSize.getWidth()
      const pageHeight = doc.internal.pageSize.getHeight()
      const colorNaranja = [234, 130, 21]
      const colorGris = [108, 117, 125]

      doc.setFillColor(...colorNaranja)
      doc.rect(0, 0, pageWidth, 35, 'F')

      doc.setFontSize(22)
      doc.setTextColor(255, 255, 255)
      doc.setFont('helvetica', 'bold')
      doc.text('GOBIERNO MUNICIPAL', pageWidth / 2, 12, { align: 'center' })
      doc.text('GUADALAJARA', pageWidth / 2, 20, { align: 'center' })

      doc.setFontSize(12)
      doc.setFont('helvetica', 'normal')
      doc.text('Tesorería Municipal', pageWidth / 2, 28, { align: 'center' })

      doc.setTextColor(0, 0, 0)
      doc.setFontSize(16)
      doc.setFont('helvetica', 'bold')
      const tipoDoc = (documento.tipo_documento || 'DOCUMENTO').toUpperCase()
      doc.text(`REIMPRESIÓN DE ${tipoDoc}`, pageWidth / 2, 48, { align: 'center' })

      doc.setFontSize(10)
      doc.setFont('helvetica', 'italic')
      doc.setTextColor(...colorGris)
      const formato = documento.formato_impresion || 'ORIGINAL'
      doc.text(`Formato: ${formato.toUpperCase()}`, pageWidth / 2, 54, { align: 'center' })

      doc.setTextColor(0, 0, 0)
      doc.setFont('helvetica', 'normal')

      let yPos = 65

      doc.setFillColor(245, 245, 245)
      doc.rect(15, yPos - 5, pageWidth - 30, 12, 'F')
      doc.setFontSize(14)
      doc.setFont('helvetica', 'bold')
      doc.text(`Folio: ${documento.folio || 'N/A'}`, 20, yPos)

      const estatus = documento.estatus || 'PENDIENTE'
      let estatusColor = [108, 117, 125]
      if (estatus === 'PAGADO') estatusColor = [40, 167, 69]
      else if (estatus === 'CANCELADO') estatusColor = [220, 53, 69]
      else if (estatus === 'PENDIENTE') estatusColor = [255, 193, 7]

      doc.setTextColor(...estatusColor)
      doc.text(`Estatus: ${estatus}`, pageWidth - 20, yPos, { align: 'right' })

      doc.setTextColor(0, 0, 0)
      yPos += 18

      const datosTabla = [
        ['Dependencia', String(documento.dependencia || 'N/A')],
        ['Año de Acta', String(documento.axo_acta || 'N/A')],
        ['Número de Acta', String(documento.num_acta || 'N/A')],
        ['Fecha', documento.fecha ? formatearFecha(documento.fecha) : 'N/A'],
        ['Contribuyente', String(documento.contribuyente || 'N/A')],
        ['Domicilio', String(documento.domicilio || 'N/A')]
      ]

      doc.autoTable({
        startY: yPos,
        head: [['Campo', 'Valor']],
        body: datosTabla,
        theme: 'striped',
        headStyles: {
          fillColor: colorNaranja,
          textColor: [255, 255, 255],
          fontStyle: 'bold',
          fontSize: 11
        },
        bodyStyles: {
          fontSize: 10
        },
        columnStyles: {
          0: { fontStyle: 'bold', cellWidth: 45 },
          1: { cellWidth: 'auto' }
        },
        margin: { left: 15, right: 15 }
      })

      yPos = doc.lastAutoTable.finalY + 12

      doc.setFontSize(12)
      doc.setFont('helvetica', 'bold')
      doc.text('Detalle de Importes', 15, yPos)
      yPos += 5

      const importesTabla = [
        ['Calificación', formatearMoneda(documento.calificacion)],
        ['Multa', formatearMoneda(documento.multa)],
        ['Gastos', formatearMoneda(documento.gastos)],
        ['Total', formatearMoneda(documento.total)]
      ]

      doc.autoTable({
        startY: yPos,
        body: importesTabla,
        theme: 'plain',
        bodyStyles: {
          fontSize: 11
        },
        columnStyles: {
          0: {
            fontStyle: 'bold',
            cellWidth: 60,
            halign: 'left'
          },
          1: {
            cellWidth: 50,
            halign: 'right',
            fontStyle: 'bold'
          }
        },
        margin: { left: 15, right: 15 },
        didParseCell: function(data) {
          if (data.row.index === 3) {
            data.cell.styles.fillColor = colorNaranja
            data.cell.styles.textColor = [255, 255, 255]
            data.cell.styles.fontSize = 12
          }
        }
      })

      yPos = doc.lastAutoTable.finalY + 12

      if (documento.id_ley || documento.id_infraccion) {
        doc.setFontSize(10)
        doc.setFont('helvetica', 'normal')
        doc.setTextColor(...colorGris)

        if (documento.id_ley) {
          doc.text(`Ley: ${documento.id_ley}`, 15, yPos)
          yPos += 5
        }
        if (documento.id_infraccion) {
          doc.text(`Infracción: ${documento.id_infraccion}`, 15, yPos)
          yPos += 8
        }
      }

      doc.setFontSize(8)
      doc.setTextColor(...colorGris)
      doc.setFont('helvetica', 'italic')

      const fechaImpresion = new Date().toLocaleString('es-MX')
      doc.text(`Documento generado el: ${fechaImpresion}`, 15, pageHeight - 20)
      doc.text('Este documento es una reimpresión y tiene validez oficial', 15, pageHeight - 15)

      doc.setFontSize(9)
      doc.setFont('courier', 'normal')
      doc.text(`*${documento.folio}*${documento.axo_acta}*${documento.num_acta}*`, 15, pageHeight - 10)

      doc.setFont('helvetica', 'normal')
      doc.text(`Página 1 de 1`, pageWidth - 15, pageHeight - 10, { align: 'right' })

      console.log('PDF generado exitosamente')
      return doc

    } catch (error) {
      console.error('Error al generar PDF:', error)
      console.error('Stack trace:', error.stack)
      throw new Error(`Error al generar PDF: ${error.message}`)
    }
  }

  const verPDF = (documento) => {
    try {
      console.log('Iniciando vista previa de PDF')
      const doc = generarPDFMulta(documento)
      const pdfBlob = doc.output('blob')
      const pdfUrl = URL.createObjectURL(pdfBlob)
      console.log('PDF generado, abriendo en nueva pestaña')
      window.open(pdfUrl, '_blank')
    } catch (error) {
      console.error('Error en verPDF:', error)
      throw error
    }
  }

  const descargarPDF = (documento) => {
    try {
      console.log('Iniciando descarga de PDF')
      const doc = generarPDFMulta(documento)
      const nombreArchivo = `${documento.tipo_documento}_${documento.folio}_${documento.axo_acta}.pdf`
      console.log('PDF generado, descargando:', nombreArchivo)
      doc.save(nombreArchivo)
    } catch (error) {
      console.error('Error en descargarPDF:', error)
      throw error
    }
  }

  const formatearFecha = (fecha) => {
    if (!fecha) return 'N/A'
    const date = new Date(fecha)
    return date.toLocaleDateString('es-MX', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
  }

  const formatearMoneda = (amount) => {
    if (!amount && amount !== 0) return '$0.00'
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN'
    }).format(amount)
  }

  return {
    generarPDFMulta,
    verPDF,
    descargarPDF
  }
}
