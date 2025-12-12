/**
 * Composable para generar PDFs de documentos fiscales
 * Especializado en multas, recibos, requerimientos y actas
 */
export function usePdfGenerator() {

  /**
   * Configuración del encabezado municipal
   */
  const headerConfig = {
    title: 'Gobierno Municipal de Guadalajara',
    subtitle: 'Dirección de Padrón y Licencias',
    logo: '/img/escudo-gdl.png'
  }

  /**
   * Escapa caracteres HTML para prevenir XSS
   */
  const escapeHtml = (text) => {
    if (text === null || text === undefined) return ''
    if (typeof text !== 'string') return String(text)
    const map = {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#039;'
    }
    return text.replace(/[&<>"']/g, m => map[m])
  }

  /**
   * Formatea fecha para mostrar
   */
  const formatDate = (dateString) => {
    if (!dateString) return 'N/A'
    const date = new Date(dateString)
    if (isNaN(date.getTime())) return escapeHtml(dateString)
    return date.toLocaleDateString('es-MX', {
      day: '2-digit',
      month: 'long',
      year: 'numeric'
    })
  }

  /**
   * Formatea moneda
   */
  const formatCurrency = (amount) => {
    if (!amount && amount !== 0) return '$0.00'
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN'
    }).format(amount)
  }

  /**
   * Genera HTML para multa
   */
  const generateMultaHtml = (documento) => {
    const currentDate = new Date().toLocaleDateString('es-MX')

    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>MULTA #${documento.folio}</title>
        <style>
          @media print {
            @page { size: letter; margin: 2cm; }
            body { -webkit-print-color-adjust: exact; }
          }
          body {
            font-family: Arial, sans-serif;
            font-size: 12px;
            line-height: 1.5;
            margin: 0;
            padding: 30px;
            color: #333;
          }
          .header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 3px solid #ea8215;
          }
          .header h1 {
            color: #ea8215;
            margin: 0 0 5px 0;
            font-size: 20px;
          }
          .header h2 {
            color: #666;
            margin: 0 0 10px 0;
            font-size: 14px;
            font-weight: normal;
          }
          .doc-type {
            background: #ea8215;
            color: white;
            padding: 10px;
            text-align: center;
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 20px;
            border-radius: 5px;
          }
          .info-section {
            margin: 20px 0;
            background: #f9f9f9;
            padding: 15px;
            border-left: 4px solid #ea8215;
            border-radius: 4px;
          }
          .info-row {
            display: flex;
            margin: 8px 0;
            padding: 5px 0;
          }
          .info-label {
            font-weight: bold;
            width: 180px;
            color: #555;
          }
          .info-value {
            flex: 1;
            color: #333;
          }
          .amount-section {
            margin: 30px 0;
            padding: 20px;
            background: #fff3e0;
            border: 2px solid #ea8215;
            border-radius: 8px;
            text-align: center;
          }
          .amount-label {
            font-size: 14px;
            color: #666;
            margin-bottom: 10px;
          }
          .amount-value {
            font-size: 28px;
            font-weight: bold;
            color: #ea8215;
          }
          .footer {
            margin-top: 40px;
            padding-top: 15px;
            border-top: 2px solid #ddd;
            font-size: 10px;
            color: #666;
            text-align: center;
          }
          .watermark {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) rotate(-45deg);
            font-size: 80px;
            color: rgba(234, 130, 21, 0.1);
            font-weight: bold;
            z-index: -1;
          }
        </style>
      </head>
      <body>
        <div class="watermark">${documento.estatus || 'MULTA'}</div>

        <div class="header">
          <h1>${escapeHtml(headerConfig.title)}</h1>
          <h2>${escapeHtml(headerConfig.subtitle)}</h2>
        </div>

        <div class="doc-type">
          MULTA ADMINISTRATIVA
        </div>

        <div class="info-section">
          <div class="info-row">
            <span class="info-label">Folio:</span>
            <span class="info-value">${escapeHtml(documento.folio || 'N/A')}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Acta:</span>
            <span class="info-value">${escapeHtml(documento.num_acta || 'N/A')} / ${escapeHtml(documento.axo_acta || 'N/A')}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Dependencia:</span>
            <span class="info-value">${escapeHtml(documento.dependencia || 'N/A')}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Fecha:</span>
            <span class="info-value">${formatDate(documento.fecha)}</span>
          </div>
        </div>

        <div class="info-section">
          <div class="info-row">
            <span class="info-label">Contribuyente:</span>
            <span class="info-value">${escapeHtml(documento.contribuyente || 'N/A')}</span>
          </div>
        </div>

        <div class="amount-section">
          <div class="amount-label">IMPORTE A PAGAR</div>
          <div class="amount-value">${formatCurrency(documento.importe)}</div>
        </div>

        <div class="info-section">
          <div class="info-row">
            <span class="info-label">Estatus:</span>
            <span class="info-value" style="font-weight: bold; color: ${documento.estatus?.toLowerCase() === 'pagado' ? '#28a745' : '#ffc107'};">
              ${escapeHtml(documento.estatus || 'N/A')}
            </span>
          </div>
        </div>

        <div class="footer">
          <p><strong>Este documento es una reimpresión</strong></p>
          <p>Generado: ${currentDate} | Sistema RefactorX</p>
          <p>Para verificar la autenticidad de este documento, favor de consultar en oficinas municipales</p>
        </div>
      </body>
      </html>
    `
  }

  /**
   * Genera HTML para recibo de pago
   */
  const generateReciboHtml = (documento) => {
    const currentDate = new Date().toLocaleDateString('es-MX')

    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>RECIBO #${documento.folio}</title>
        <style>
          @media print {
            @page { size: letter; margin: 2cm; }
            body { -webkit-print-color-adjust: exact; }
          }
          body {
            font-family: Arial, sans-serif;
            font-size: 12px;
            line-height: 1.5;
            margin: 0;
            padding: 30px;
            color: #333;
          }
          .header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 3px solid #28a745;
          }
          .header h1 {
            color: #28a745;
            margin: 0 0 5px 0;
            font-size: 20px;
          }
          .header h2 {
            color: #666;
            margin: 0 0 10px 0;
            font-size: 14px;
            font-weight: normal;
          }
          .doc-type {
            background: #28a745;
            color: white;
            padding: 10px;
            text-align: center;
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 20px;
            border-radius: 5px;
          }
          .info-section {
            margin: 20px 0;
            background: #f9f9f9;
            padding: 15px;
            border-left: 4px solid #28a745;
            border-radius: 4px;
          }
          .info-row {
            display: flex;
            margin: 8px 0;
            padding: 5px 0;
          }
          .info-label {
            font-weight: bold;
            width: 180px;
            color: #555;
          }
          .info-value {
            flex: 1;
            color: #333;
          }
          .amount-section {
            margin: 30px 0;
            padding: 20px;
            background: #e8f5e9;
            border: 2px solid #28a745;
            border-radius: 8px;
            text-align: center;
          }
          .amount-label {
            font-size: 14px;
            color: #666;
            margin-bottom: 10px;
          }
          .amount-value {
            font-size: 28px;
            font-weight: bold;
            color: #28a745;
          }
          .paid-stamp {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) rotate(-45deg);
            font-size: 80px;
            color: rgba(40, 167, 69, 0.1);
            font-weight: bold;
            z-index: -1;
          }
          .footer {
            margin-top: 40px;
            padding-top: 15px;
            border-top: 2px solid #ddd;
            font-size: 10px;
            color: #666;
            text-align: center;
          }
        </style>
      </head>
      <body>
        <div class="paid-stamp">PAGADO</div>

        <div class="header">
          <h1>${escapeHtml(headerConfig.title)}</h1>
          <h2>${escapeHtml(headerConfig.subtitle)}</h2>
        </div>

        <div class="doc-type">
          RECIBO DE PAGO OFICIAL
        </div>

        <div class="info-section">
          <div class="info-row">
            <span class="info-label">Folio de Recibo:</span>
            <span class="info-value">${escapeHtml(documento.folio || 'N/A')}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Referencia:</span>
            <span class="info-value">${escapeHtml(documento.num_acta || 'N/A')} / ${escapeHtml(documento.axo_acta || 'N/A')}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Fecha de Pago:</span>
            <span class="info-value">${formatDate(documento.fecha)}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Dependencia:</span>
            <span class="info-value">${escapeHtml(documento.dependencia || 'N/A')}</span>
          </div>
        </div>

        <div class="info-section">
          <div class="info-row">
            <span class="info-label">Contribuyente:</span>
            <span class="info-value">${escapeHtml(documento.contribuyente || 'N/A')}</span>
          </div>
        </div>

        <div class="amount-section">
          <div class="amount-label">IMPORTE PAGADO</div>
          <div class="amount-value">${formatCurrency(documento.importe)}</div>
        </div>

        <div class="footer">
          <p><strong>Este documento es una reimpresión del recibo oficial de pago</strong></p>
          <p>Generado: ${currentDate} | Sistema RefactorX</p>
          <p>Conserve este documento como comprobante de pago</p>
        </div>
      </body>
      </html>
    `
  }

  /**
   * Genera HTML para requerimiento
   */
  const generateRequerimientoHtml = (documento) => {
    const currentDate = new Date().toLocaleDateString('es-MX')

    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>REQUERIMIENTO #${documento.folio}</title>
        <style>
          @media print {
            @page { size: letter; margin: 2cm; }
            body { -webkit-print-color-adjust: exact; }
          }
          body {
            font-family: Arial, sans-serif;
            font-size: 12px;
            line-height: 1.5;
            margin: 0;
            padding: 30px;
            color: #333;
          }
          .header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 3px solid #dc3545;
          }
          .header h1 {
            color: #dc3545;
            margin: 0 0 5px 0;
            font-size: 20px;
          }
          .header h2 {
            color: #666;
            margin: 0 0 10px 0;
            font-size: 14px;
            font-weight: normal;
          }
          .doc-type {
            background: #dc3545;
            color: white;
            padding: 10px;
            text-align: center;
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 20px;
            border-radius: 5px;
          }
          .info-section {
            margin: 20px 0;
            background: #f9f9f9;
            padding: 15px;
            border-left: 4px solid #dc3545;
            border-radius: 4px;
          }
          .info-row {
            display: flex;
            margin: 8px 0;
            padding: 5px 0;
          }
          .info-label {
            font-weight: bold;
            width: 180px;
            color: #555;
          }
          .info-value {
            flex: 1;
            color: #333;
          }
          .warning-box {
            margin: 30px 0;
            padding: 20px;
            background: #fff3cd;
            border: 2px solid #ffc107;
            border-radius: 8px;
          }
          .warning-title {
            font-size: 16px;
            font-weight: bold;
            color: #856404;
            margin-bottom: 10px;
          }
          .warning-text {
            color: #856404;
            line-height: 1.8;
          }
          .footer {
            margin-top: 40px;
            padding-top: 15px;
            border-top: 2px solid #ddd;
            font-size: 10px;
            color: #666;
            text-align: center;
          }
        </style>
      </head>
      <body>
        <div class="header">
          <h1>${escapeHtml(headerConfig.title)}</h1>
          <h2>${escapeHtml(headerConfig.subtitle)}</h2>
        </div>

        <div class="doc-type">
          REQUERIMIENTO DE PAGO
        </div>

        <div class="info-section">
          <div class="info-row">
            <span class="info-label">Folio:</span>
            <span class="info-value">${escapeHtml(documento.folio || 'N/A')}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Acta:</span>
            <span class="info-value">${escapeHtml(documento.num_acta || 'N/A')} / ${escapeHtml(documento.axo_acta || 'N/A')}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Dependencia:</span>
            <span class="info-value">${escapeHtml(documento.dependencia || 'N/A')}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Fecha de Notificación:</span>
            <span class="info-value">${formatDate(documento.fecha)}</span>
          </div>
        </div>

        <div class="info-section">
          <div class="info-row">
            <span class="info-label">Contribuyente:</span>
            <span class="info-value">${escapeHtml(documento.contribuyente || 'N/A')}</span>
          </div>
        </div>

        <div class="warning-box">
          <div class="warning-title">⚠️ AVISO IMPORTANTE</div>
          <div class="warning-text">
            <p>Se le notifica que tiene un adeudo pendiente por un importe de <strong>${formatCurrency(documento.importe)}</strong>.</p>
            <p>De no realizar el pago correspondiente en los plazos establecidos por la ley, se procederá conforme a derecho.</p>
          </div>
        </div>

        <div class="footer">
          <p><strong>Este documento es una reimpresión</strong></p>
          <p>Generado: ${currentDate} | Sistema RefactorX</p>
          <p>Para más información, acuda a las oficinas municipales</p>
        </div>
      </body>
      </html>
    `
  }

  /**
   * Genera HTML para acta administrativa
   */
  const generateActaHtml = (documento) => {
    const currentDate = new Date().toLocaleDateString('es-MX')

    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>ACTA #${documento.num_acta}</title>
        <style>
          @media print {
            @page { size: letter; margin: 2cm; }
            body { -webkit-print-color-adjust: exact; }
          }
          body {
            font-family: 'Times New Roman', serif;
            font-size: 12px;
            line-height: 1.8;
            margin: 0;
            padding: 30px;
            color: #333;
          }
          .header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 3px solid #17a2b8;
          }
          .header h1 {
            color: #17a2b8;
            margin: 0 0 5px 0;
            font-size: 20px;
          }
          .header h2 {
            color: #666;
            margin: 0 0 10px 0;
            font-size: 14px;
            font-weight: normal;
          }
          .doc-type {
            background: #17a2b8;
            color: white;
            padding: 10px;
            text-align: center;
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 20px;
            border-radius: 5px;
          }
          .info-section {
            margin: 20px 0;
            background: #f9f9f9;
            padding: 15px;
            border-left: 4px solid #17a2b8;
            border-radius: 4px;
          }
          .info-row {
            display: flex;
            margin: 8px 0;
            padding: 5px 0;
          }
          .info-label {
            font-weight: bold;
            width: 180px;
            color: #555;
          }
          .info-value {
            flex: 1;
            color: #333;
          }
          .content-section {
            margin: 30px 0;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 4px;
            text-align: justify;
          }
          .footer {
            margin-top: 40px;
            padding-top: 15px;
            border-top: 2px solid #ddd;
            font-size: 10px;
            color: #666;
            text-align: center;
          }
          .signature-section {
            margin-top: 60px;
            display: flex;
            justify-content: space-around;
          }
          .signature-box {
            text-align: center;
            width: 200px;
          }
          .signature-line {
            border-top: 1px solid #333;
            margin-top: 60px;
            padding-top: 5px;
          }
        </style>
      </head>
      <body>
        <div class="header">
          <h1>${escapeHtml(headerConfig.title)}</h1>
          <h2>${escapeHtml(headerConfig.subtitle)}</h2>
        </div>

        <div class="doc-type">
          ACTA ADMINISTRATIVA
        </div>

        <div class="info-section">
          <div class="info-row">
            <span class="info-label">Número de Acta:</span>
            <span class="info-value">${escapeHtml(documento.num_acta || 'N/A')}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Año:</span>
            <span class="info-value">${escapeHtml(documento.axo_acta || 'N/A')}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Folio:</span>
            <span class="info-value">${escapeHtml(documento.folio || 'N/A')}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Dependencia:</span>
            <span class="info-value">${escapeHtml(documento.dependencia || 'N/A')}</span>
          </div>
          <div class="info-row">
            <span class="info-label">Fecha:</span>
            <span class="info-value">${formatDate(documento.fecha)}</span>
          </div>
        </div>

        <div class="info-section">
          <div class="info-row">
            <span class="info-label">Infractor:</span>
            <span class="info-value">${escapeHtml(documento.contribuyente || 'N/A')}</span>
          </div>
        </div>

        <div class="content-section">
          <p style="margin-top: 0;">
            En la ciudad de Guadalajara, Jalisco, siendo las ____ horas del día ${formatDate(documento.fecha)},
            se levanta la presente acta administrativa por la autoridad competente.
          </p>
          <p>
            Se hace constar que el contribuyente <strong>${escapeHtml(documento.contribuyente || 'N/A')}</strong>
            ha incurrido en infracciones a los reglamentos municipales vigentes.
          </p>
          <p>
            El importe de la sanción correspondiente asciende a <strong>${formatCurrency(documento.importe)}</strong>,
            mismo que deberá ser cubierto en los plazos establecidos por la ley.
          </p>
        </div>

        <div class="signature-section">
          <div class="signature-box">
            <div class="signature-line">
              Firma del Inspector
            </div>
          </div>
          <div class="signature-box">
            <div class="signature-line">
              Firma del Infractor
            </div>
          </div>
        </div>

        <div class="footer">
          <p><strong>Este documento es una reimpresión</strong></p>
          <p>Generado: ${currentDate} | Sistema RefactorX</p>
        </div>
      </body>
      </html>
    `
  }

  /**
   * Genera el HTML apropiado según el tipo de documento
   */
  const generateDocumentHtml = (documento) => {
    const tipo = (documento.tipo_documento || 'multa').toLowerCase()

    switch (tipo) {
      case 'recibo':
        return generateReciboHtml(documento)
      case 'requerimiento':
        return generateRequerimientoHtml(documento)
      case 'acta':
        return generateActaHtml(documento)
      case 'multa':
      default:
        return generateMultaHtml(documento)
    }
  }

  /**
   * Muestra vista previa del PDF en nueva ventana
   * @param {Object} documento - Objeto con datos del documento
   */
  const verPDF = (documento) => {
    if (!documento) {
      throw new Error('No se proporcionó documento para generar PDF')
    }

    try {
      const html = generateDocumentHtml(documento)

      // Abrir nueva ventana
      const printWindow = window.open('', '_blank', 'width=900,height=700')

      if (!printWindow) {
        throw new Error('No se pudo abrir ventana. Verifique el bloqueador de popups.')
      }

      printWindow.document.write(html)
      printWindow.document.close()

      console.log('✅ Vista previa del PDF generada')

      return true
    } catch (error) {
      console.error('❌ Error al generar vista previa:', error)
      throw error
    }
  }

  /**
   * Descarga el PDF del documento
   * @param {Object} documento - Objeto con datos del documento
   */
  const descargarPDF = (documento) => {
    if (!documento) {
      throw new Error('No se proporcionó documento para descargar')
    }

    try {
      const html = generateDocumentHtml(documento)

      // Generar nombre de archivo
      const tipo = documento.tipo_documento || 'documento'
      const folio = documento.folio || 'sin_folio'
      const fecha = new Date().toISOString().split('T')[0]
      const filename = `${tipo}_${folio}_${fecha}.pdf`

      // Abrir ventana para imprimir/descargar
      const printWindow = window.open('', '_blank', 'width=900,height=700')

      if (!printWindow) {
        throw new Error('No se pudo abrir ventana. Verifique el bloqueador de popups.')
      }

      printWindow.document.write(html)
      printWindow.document.close()

      // Esperar a que cargue y disparar impresión
      printWindow.onload = () => {
        setTimeout(() => {
          printWindow.print()
        }, 250)
      }

      console.log(`✅ PDF listo para descargar: ${filename}`)

      return true
    } catch (error) {
      console.error('❌ Error al descargar PDF:', error)
      throw error
    }
  }

  /**
   * Genera HTML para reportes tabulares
   * @param {Array} datos - Array de objetos con los datos
   * @param {Object} opciones - Configuración del reporte
   */
  const generateReporteTabularHtml = (datos, opciones) => {
    const {
      titulo = 'Reporte',
      subtitulo = '',
      ejercicio = '',
      columnas = [],
      totales = {}
    } = opciones

    const currentDate = new Date().toLocaleDateString('es-MX', {
      day: '2-digit',
      month: 'long',
      year: 'numeric'
    })

    // Generar filas de datos
    const dataRows = datos.map(item => {
      return `<tr>
        ${columnas.map(col => {
          let value = item[col.key]
          let formattedValue = ''

          if (col.type === 'currency') {
            formattedValue = formatCurrency(value)
          } else if (col.type === 'number') {
            formattedValue = new Intl.NumberFormat('es-MX').format(value || 0)
          } else {
            formattedValue = escapeHtml(value)
          }

          const align = (col.type === 'currency' || col.type === 'number') ? 'right' : 'left'
          return `<td style="text-align: ${align}; padding: 8px; border: 1px solid #ddd;">${formattedValue}</td>`
        }).join('')}
      </tr>`
    }).join('')

    // Generar fila de totales
    let totalRow = ''
    if (totales && Object.keys(totales).length > 0) {
      totalRow = `<tr style="font-weight: bold; background: linear-gradient(135deg, #ea8215 0%, #d67512 100%); color: white;">
        ${columnas.map((col, index) => {
          if (index === 0) {
            return `<td style="padding: 10px; border: 1px solid #ea8215;"><strong>TOTALES</strong></td>`
          }
          if (totales[col.key] !== undefined) {
            let value = totales[col.key]
            let formattedValue = ''
            if (col.type === 'currency') {
              formattedValue = formatCurrency(value)
            } else if (col.type === 'number') {
              formattedValue = new Intl.NumberFormat('es-MX').format(value || 0)
            } else {
              formattedValue = escapeHtml(value)
            }
            const align = (col.type === 'currency' || col.type === 'number') ? 'right' : 'left'
            return `<td style="text-align: ${align}; padding: 10px; border: 1px solid #ea8215;"><strong>${formattedValue}</strong></td>`
          }
          return `<td style="padding: 10px; border: 1px solid #ea8215;"></td>`
        }).join('')}
      </tr>`
    }

    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>${titulo}</title>
        <style>
          @media print {
            @page {
              size: landscape;
              margin: 1.5cm;
            }
            body { -webkit-print-color-adjust: exact; }
          }
          body {
            font-family: Arial, sans-serif;
            font-size: 11px;
            line-height: 1.4;
            color: #333;
            margin: 0;
            padding: 20px;
          }
          .header {
            text-align: center;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 3px solid #ea8215;
          }
          .header h1 {
            color: #ea8215;
            margin: 0 0 5px 0;
            font-size: 20px;
          }
          .header h2 {
            color: #666;
            margin: 0 0 5px 0;
            font-size: 14px;
            font-weight: normal;
          }
          .header h3 {
            color: #333;
            margin: 10px 0 0 0;
            font-size: 16px;
          }
          .subtitle {
            text-align: center;
            color: #666;
            margin-bottom: 20px;
            font-size: 13px;
          }
          .meta {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
            font-size: 10px;
            color: #666;
            padding: 10px;
            background: #f8f9fa;
            border-radius: 4px;
          }
          table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
          }
          thead th {
            background: linear-gradient(135deg, #ea8215 0%, #d67512 100%);
            color: white;
            padding: 10px 8px;
            text-align: left;
            font-weight: bold;
            font-size: 11px;
            border: 1px solid #ea8215;
          }
          tbody tr:nth-child(even) {
            background-color: #f9f9f9;
          }
          tbody tr:hover {
            background-color: #fff3e6;
          }
          .footer {
            margin-top: 25px;
            padding-top: 15px;
            border-top: 2px solid #ddd;
            font-size: 9px;
            color: #666;
            text-align: center;
          }
          .total-records {
            margin-top: 10px;
            font-size: 10px;
            color: #666;
            font-weight: bold;
          }
        </style>
      </head>
      <body>
        <div class="header">
          <h1>${escapeHtml(headerConfig.title)}</h1>
          <h2>${escapeHtml(headerConfig.subtitle)}</h2>
          <h3>${escapeHtml(titulo)}</h3>
        </div>

        ${subtitulo ? `<div class="subtitle">${escapeHtml(subtitulo)}</div>` : ''}

        <div class="meta">
          <span><strong>Ejercicio:</strong> ${escapeHtml(ejercicio)}</span>
          <span><strong>Total de registros:</strong> ${datos.length}</span>
          <span><strong>Fecha de generación:</strong> ${currentDate}</span>
        </div>

        <table>
          <thead>
            <tr>
              ${columnas.map(col => {
                const align = (col.type === 'currency' || col.type === 'number') ? 'right' : 'left'
                return `<th style="text-align: ${align};">${escapeHtml(col.header)}</th>`
              }).join('')}
            </tr>
          </thead>
          <tbody>
            ${dataRows}
          </tbody>
          ${totalRow ? `<tfoot>${totalRow}</tfoot>` : ''}
        </table>

        <div class="total-records">
          Total de dependencias: ${datos.length}
        </div>

        <div class="footer">
          <p>Documento generado por Sistema RefactorX - ${currentDate}</p>
          <p>Gobierno Municipal de Guadalajara - Dirección de Padrón y Licencias</p>
        </div>
      </body>
      </html>
    `
  }

  /**
   * Genera y muestra reporte tabular en nueva ventana
   * @param {Array} datos - Array de objetos con los datos
   * @param {Object} opciones - Configuración del reporte
   */
  const verReporteTabular = (datos, opciones) => {
    if (!datos || datos.length === 0) {
      throw new Error('No hay datos para generar el reporte')
    }

    try {
      const html = generateReporteTabularHtml(datos, opciones)

      // Abrir nueva ventana
      const printWindow = window.open('', '_blank', 'width=1024,height=768')

      if (!printWindow) {
        throw new Error('No se pudo abrir ventana. Verifique el bloqueador de popups.')
      }

      printWindow.document.write(html)
      printWindow.document.close()

      console.log('✅ Reporte tabular generado')

      return true
    } catch (error) {
      console.error('❌ Error al generar reporte:', error)
      throw error
    }
  }

  /**
   * Descarga el reporte tabular en PDF
   * @param {Array} datos - Array de objetos con los datos del reporte
   * @param {Object} opciones - Configuración del reporte
   */
  const descargarReporteTabular = (datos, opciones) => {
    if (!datos || datos.length === 0) {
      throw new Error('No hay datos para generar el reporte')
    }

    if (!opciones || !opciones.titulo) {
      throw new Error('Se requiere configurar el título del reporte')
    }

    try {
      const html = generateReporteTabularHtml(datos, opciones)

      // Generar nombre de archivo
      const fecha = new Date().toISOString().split('T')[0]
      const tituloLimpio = opciones.titulo.toLowerCase().replace(/\s+/g, '_')
      const ejercicio = opciones.ejercicio || ''
      const filename = `${tituloLimpio}_${ejercicio}_${fecha}.pdf`

      // Abrir ventana para imprimir/descargar
      const printWindow = window.open('', '_blank', 'width=1100,height=700')

      if (!printWindow) {
        throw new Error('No se pudo abrir ventana. Verifique el bloqueador de popups.')
      }

      printWindow.document.write(html)
      printWindow.document.close()

      // Esperar a que cargue y disparar impresión
      printWindow.onload = () => {
        setTimeout(() => {
          printWindow.print()
        }, 250)
      }

      console.log(`✅ Reporte listo para descargar: ${filename}`)

      return true
    } catch (error) {
      console.error('❌ Error al descargar reporte:', error)
      throw error
    }
  }

  return {
    verPDF,
    descargarPDF,
    verReporteTabular,
    descargarReporteTabular
  }
}
