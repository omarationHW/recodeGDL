/**
 * Composable para exportar datos a PDF
 * Funciona 100% en frontend usando la API nativa del navegador
 * No requiere librerías externas (jsPDF opcional)
 */
export function usePdfExport() {

  /**
   * Configuración del encabezado municipal
   */
  const headerConfig = {
    title: 'Gobierno Municipal de Guadalajara',
    subtitle: 'Dirección de Padrón y Licencias',
    logo: '/img/escudo-gdl.png' // Ajustar ruta según proyecto
  }

  /**
   * Escapa caracteres HTML para prevenir XSS
   * @param {any} text - Texto a escapar
   * @returns {string} Texto escapado seguro para HTML
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
   * Formatea un valor para mostrar en PDF
   */
  const formatValue = (value, type) => {
    if (value === null || value === undefined) return ''

    switch (type) {
      case 'date':
        if (!value) return ''
        const date = new Date(value)
        if (isNaN(date.getTime())) return escapeHtml(value)
        return date.toLocaleDateString('es-MX')

      case 'datetime':
        if (!value) return ''
        const datetime = new Date(value)
        if (isNaN(datetime.getTime())) return escapeHtml(value)
        return datetime.toLocaleString('es-MX')

      case 'currency':
        const num = parseFloat(value)
        if (isNaN(num)) return escapeHtml(value)
        return new Intl.NumberFormat('es-MX', {
          style: 'currency',
          currency: 'MXN'
        }).format(num)

      case 'number':
        return new Intl.NumberFormat('es-MX').format(parseFloat(value) || 0)

      default:
        return escapeHtml(String(value))
    }
  }

  /**
   * Genera el HTML de la tabla para el PDF
   */
  const generateTableHtml = (data, columns, options = {}) => {
    const {
      title = 'Reporte',
      subtitle = '',
      showDate = true,
      showTotal = false,
      totalColumns = []
    } = options

    const currentDate = new Date().toLocaleString('es-MX')

    // Calcular totales si es necesario
    let totals = {}
    if (showTotal && totalColumns.length > 0) {
      totalColumns.forEach(key => {
        totals[key] = data.reduce((sum, item) => {
          const val = parseFloat(item[key]) || 0
          return sum + val
        }, 0)
      })
    }

    // Generar filas de datos
    const dataRows = data.map(item => {
      return `<tr>
        ${columns.map(col => {
          const value = formatValue(item[col.key], col.type)
          const align = col.type === 'currency' || col.type === 'number' ? 'right' : 'left'
          return `<td style="text-align: ${align}; padding: 6px 8px; border-bottom: 1px solid #ddd;">${value}</td>`
        }).join('')}
      </tr>`
    }).join('')

    // Generar fila de totales
    let totalRow = ''
    if (showTotal && totalColumns.length > 0) {
      totalRow = `<tr style="font-weight: bold; background-color: #f5f5f5;">
        ${columns.map((col, index) => {
          if (index === 0) {
            return `<td style="padding: 8px; border-top: 2px solid #333;">TOTAL</td>`
          }
          if (totalColumns.includes(col.key)) {
            const value = formatValue(totals[col.key], col.type)
            return `<td style="text-align: right; padding: 8px; border-top: 2px solid #333;">${value}</td>`
          }
          return `<td style="padding: 8px; border-top: 2px solid #333;"></td>`
        }).join('')}
      </tr>`
    }

    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>${title}</title>
        <style>
          @media print {
            @page {
              size: ${options.orientation === 'landscape' ? 'landscape' : 'portrait'};
              margin: 1cm;
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
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #8B0000;
          }
          .header h1 {
            color: #8B0000;
            margin: 0 0 5px 0;
            font-size: 18px;
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
          .meta {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
            font-size: 10px;
            color: #666;
          }
          table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
          }
          thead th {
            background-color: #8B0000;
            color: white;
            padding: 8px;
            text-align: left;
            font-weight: bold;
            font-size: 10px;
          }
          tbody tr:nth-child(even) {
            background-color: #f9f9f9;
          }
          tbody tr:hover {
            background-color: #f0f0f0;
          }
          .footer {
            margin-top: 20px;
            padding-top: 10px;
            border-top: 1px solid #ddd;
            font-size: 9px;
            color: #666;
            text-align: center;
          }
          .total-records {
            margin-top: 10px;
            font-size: 10px;
            color: #666;
          }
        </style>
      </head>
      <body>
        <div class="header">
          <h1>${escapeHtml(headerConfig.title)}</h1>
          <h2>${escapeHtml(headerConfig.subtitle)}</h2>
          <h3>${escapeHtml(title)}</h3>
          ${subtitle ? `<p style="margin: 5px 0 0 0; color: #666;">${escapeHtml(subtitle)}</p>` : ''}
        </div>

        <div class="meta">
          <span>Total de registros: ${data.length}</span>
          ${showDate ? `<span>Fecha de generación: ${currentDate}</span>` : ''}
        </div>

        <table>
          <thead>
            <tr>
              ${columns.map(col => {
                const align = col.type === 'currency' || col.type === 'number' ? 'right' : 'left'
                return `<th style="text-align: ${align};">${escapeHtml(col.header)}</th>`
              }).join('')}
            </tr>
          </thead>
          <tbody>
            ${dataRows}
            ${totalRow}
          </tbody>
        </table>

        <div class="footer">
          <p>Documento generado por Sistema RefactorX - ${currentDate}</p>
        </div>
      </body>
      </html>
    `
  }

  /**
   * Exporta datos a PDF usando la ventana de impresión del navegador
   * @param {Array} data - Array de objetos con los datos
   * @param {Array} columns - Definición de columnas [{header, key, type?, width?}]
   * @param {Object} options - Opciones de configuración
   */
  const exportToPdf = (data, columns, options = {}) => {
    if (!data || data.length === 0) {
      console.warn('usePdfExport: No hay datos para exportar')
      return false
    }

    try {
      const html = generateTableHtml(data, columns, options)

      // Abrir nueva ventana para impresión
      const printWindow = window.open('', '_blank', 'width=900,height=700')

      if (!printWindow) {
        console.error('usePdfExport: No se pudo abrir ventana de impresión. Verifique el bloqueador de popups.')
        return false
      }

      printWindow.document.write(html)
      printWindow.document.close()

      // Esperar a que cargue y luego imprimir
      printWindow.onload = () => {
        setTimeout(() => {
          printWindow.print()
        }, 250)
      }

      return true
    } catch (error) {
      console.error('usePdfExport: Error al exportar', error)
      return false
    }
  }

  /**
   * Genera una vista previa del PDF en un modal o nueva pestaña
   * @param {Array} data - Datos a mostrar
   * @param {Array} columns - Columnas
   * @param {Object} options - Opciones
   * @returns {string} HTML generado
   */
  const generatePreview = (data, columns, options = {}) => {
    return generateTableHtml(data, columns, options)
  }

  /**
   * Imprime directamente sin mostrar diálogo (si el navegador lo permite)
   */
  const printDirect = (data, columns, options = {}) => {
    const html = generateTableHtml(data, columns, options)
    const iframe = document.createElement('iframe')
    iframe.style.display = 'none'
    document.body.appendChild(iframe)

    iframe.contentDocument.write(html)
    iframe.contentDocument.close()

    iframe.onload = () => {
      setTimeout(() => {
        iframe.contentWindow.print()
        setTimeout(() => {
          document.body.removeChild(iframe)
        }, 1000)
      }, 250)
    }
  }

  /**
   * Genera un documento tipo constancia/certificado
   * @param {Object} data - Datos del documento
   * @param {string} template - Tipo de plantilla
   */
  const generateDocument = (data, template, options = {}) => {
    const templates = {
      constancia_vigencia: generateConstanciaVigencia,
      estado_cuenta: generateEstadoCuenta,
      certificacion: generateCertificacion
    }

    const generator = templates[template]
    if (!generator) {
      console.error(`usePdfExport: Template '${template}' no encontrado`)
      return false
    }

    const html = generator(data, options)
    const printWindow = window.open('', '_blank', 'width=900,height=700')

    if (!printWindow) {
      return false
    }

    printWindow.document.write(html)
    printWindow.document.close()

    printWindow.onload = () => {
      setTimeout(() => {
        printWindow.print()
      }, 250)
    }

    return true
  }

  /**
   * Plantilla: Constancia de Vigencia
   */
  const generateConstanciaVigencia = (data, options = {}) => {
    const currentDate = new Date().toLocaleDateString('es-MX', {
      day: 'numeric',
      month: 'long',
      year: 'numeric'
    })

    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>Constancia de Vigencia</title>
        <style>
          @media print {
            @page { size: letter; margin: 2cm; }
          }
          body {
            font-family: 'Times New Roman', serif;
            font-size: 12pt;
            line-height: 1.6;
            max-width: 700px;
            margin: 0 auto;
            padding: 40px;
          }
          .header {
            text-align: center;
            margin-bottom: 40px;
          }
          .header h1 {
            color: #8B0000;
            font-size: 16pt;
            margin: 0;
          }
          .header h2 {
            font-size: 14pt;
            margin: 5px 0;
            font-weight: normal;
          }
          .title {
            text-align: center;
            font-size: 14pt;
            font-weight: bold;
            margin: 30px 0;
            text-decoration: underline;
          }
          .content {
            text-align: justify;
            margin: 30px 0;
          }
          .data-row {
            margin: 10px 0;
          }
          .data-label {
            font-weight: bold;
          }
          .signature {
            margin-top: 60px;
            text-align: center;
          }
          .signature-line {
            border-top: 1px solid #333;
            width: 250px;
            margin: 0 auto;
            padding-top: 5px;
          }
          .footer {
            margin-top: 40px;
            font-size: 9pt;
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

        <div class="title">CONSTANCIA DE VIGENCIA</div>

        <div class="content">
          <p>Se hace constar que la licencia con los siguientes datos se encuentra VIGENTE:</p>

          <div class="data-row">
            <span class="data-label">Número de Licencia:</span> ${escapeHtml(data.folio || 'N/A')}
          </div>
          <div class="data-row">
            <span class="data-label">Razón Social:</span> ${escapeHtml(data.razon_social || 'N/A')}
          </div>
          <div class="data-row">
            <span class="data-label">RFC:</span> ${escapeHtml(data.rfc || 'N/A')}
          </div>
          <div class="data-row">
            <span class="data-label">Giro:</span> ${escapeHtml(data.giro || 'N/A')}
          </div>
          <div class="data-row">
            <span class="data-label">Domicilio:</span> ${escapeHtml(data.domicilio || 'N/A')}
          </div>
          <div class="data-row">
            <span class="data-label">Fecha de Alta:</span> ${escapeHtml(data.fecha_alta || 'N/A')}
          </div>

          <p style="margin-top: 30px;">
            Se expide la presente constancia para los fines legales que al interesado convengan,
            en la ciudad de Guadalajara, Jalisco, a ${currentDate}.
          </p>
        </div>

        <div class="signature">
          <div class="signature-line">
            Firma y Sello
          </div>
        </div>

        <div class="footer">
          <p>Este documento no tiene validez sin firma y sello oficial</p>
        </div>
      </body>
      </html>
    `
  }

  /**
   * Plantilla: Estado de Cuenta
   */
  const generateEstadoCuenta = (data, options = {}) => {
    const currentDate = new Date().toLocaleDateString('es-MX')

    // Calcular total de adeudos
    const totalAdeudos = (data.adeudos || []).reduce((sum, a) => sum + (parseFloat(a.total) || 0), 0)

    const adeudosRows = (data.adeudos || []).map(adeudo => `
      <tr>
        <td style="padding: 6px; border: 1px solid #ddd;">${escapeHtml(adeudo.periodo || '')}</td>
        <td style="padding: 6px; border: 1px solid #ddd;">${escapeHtml(adeudo.concepto || '')}</td>
        <td style="padding: 6px; border: 1px solid #ddd; text-align: right;">${formatValue(adeudo.importe, 'currency')}</td>
        <td style="padding: 6px; border: 1px solid #ddd; text-align: right;">${formatValue(adeudo.recargos, 'currency')}</td>
        <td style="padding: 6px; border: 1px solid #ddd; text-align: right; font-weight: bold;">${formatValue(adeudo.total, 'currency')}</td>
      </tr>
    `).join('')

    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <title>Estado de Cuenta</title>
        <style>
          @media print {
            @page { size: letter; margin: 1.5cm; }
          }
          body {
            font-family: Arial, sans-serif;
            font-size: 11px;
            max-width: 700px;
            margin: 0 auto;
            padding: 20px;
          }
          .header {
            text-align: center;
            margin-bottom: 20px;
            border-bottom: 2px solid #8B0000;
            padding-bottom: 10px;
          }
          .header h1 { color: #8B0000; font-size: 16px; margin: 0; }
          .header h2 { font-size: 14px; margin: 5px 0; font-weight: normal; }
          .title { text-align: center; font-size: 14px; font-weight: bold; margin: 20px 0; }
          .info-section { margin: 15px 0; }
          .info-row { display: flex; margin: 5px 0; }
          .info-label { font-weight: bold; width: 150px; }
          table { width: 100%; border-collapse: collapse; margin: 20px 0; }
          th { background: #8B0000; color: white; padding: 8px; text-align: left; }
          .total-row { background: #f5f5f5; font-weight: bold; }
          .footer { margin-top: 30px; font-size: 9px; color: #666; text-align: center; }
        </style>
      </head>
      <body>
        <div class="header">
          <h1>${escapeHtml(headerConfig.title)}</h1>
          <h2>Estado de Cuenta</h2>
        </div>

        <div class="info-section">
          <div class="info-row"><span class="info-label">Folio:</span> ${escapeHtml(data.folio || 'N/A')}</div>
          <div class="info-row"><span class="info-label">Contribuyente:</span> ${escapeHtml(data.razon_social || 'N/A')}</div>
          <div class="info-row"><span class="info-label">RFC:</span> ${escapeHtml(data.rfc || 'N/A')}</div>
          <div class="info-row"><span class="info-label">Domicilio:</span> ${escapeHtml(data.domicilio || 'N/A')}</div>
          <div class="info-row"><span class="info-label">Fecha:</span> ${currentDate}</div>
        </div>

        <table>
          <thead>
            <tr>
              <th>Período</th>
              <th>Concepto</th>
              <th style="text-align: right;">Importe</th>
              <th style="text-align: right;">Recargos</th>
              <th style="text-align: right;">Total</th>
            </tr>
          </thead>
          <tbody>
            ${adeudosRows}
            <tr class="total-row">
              <td colspan="4" style="padding: 8px; border: 1px solid #ddd; text-align: right;">TOTAL A PAGAR:</td>
              <td style="padding: 8px; border: 1px solid #ddd; text-align: right;">${formatValue(totalAdeudos, 'currency')}</td>
            </tr>
          </tbody>
        </table>

        <div class="footer">
          <p>Este estado de cuenta es informativo. Los importes pueden variar por actualización de recargos.</p>
          <p>Generado por Sistema RefactorX - ${currentDate}</p>
        </div>
      </body>
      </html>
    `
  }

  /**
   * Plantilla: Certificación
   */
  const generateCertificacion = (data, options = {}) => {
    return generateConstanciaVigencia(data, options) // Usar misma plantilla por ahora
  }

  return {
    exportToPdf,
    generatePreview,
    printDirect,
    generateDocument,
    formatValue
  }
}
