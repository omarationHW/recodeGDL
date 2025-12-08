import * as XLSX from 'xlsx'

/**
 * Composable para exportar datos a Excel
 * Funciona 100% en frontend sin necesidad de backend
 */
export function useExcelExport() {

  /**
   * Formatea un valor para Excel según su tipo
   * @param {any} value - Valor a formatear
   * @param {string} type - Tipo de formato: 'date', 'currency', 'number', 'text'
   * @returns {any} Valor formateado
   */
  const formatValue = (value, type) => {
    if (value === null || value === undefined) return ''

    switch (type) {
      case 'date':
        if (!value) return ''
        const date = new Date(value)
        if (isNaN(date.getTime())) return value
        return date.toLocaleDateString('es-MX')

      case 'datetime':
        if (!value) return ''
        const datetime = new Date(value)
        if (isNaN(datetime.getTime())) return value
        return datetime.toLocaleString('es-MX')

      case 'currency':
        const num = parseFloat(value)
        if (isNaN(num)) return value
        return num.toFixed(2)

      case 'number':
        return parseFloat(value) || 0

      case 'integer':
        return parseInt(value) || 0

      default:
        return String(value)
    }
  }

  /**
   * Convierte datos a formato de hoja de Excel
   * @param {Array} data - Array de objetos con los datos
   * @param {Array} columns - Definición de columnas [{header, key, type?, width?}]
   * @returns {Object} Worksheet de XLSX
   */
  const dataToWorksheet = (data, columns) => {
    // Crear array con encabezados
    const headers = columns.map(col => col.header)

    // Crear filas de datos
    const rows = data.map(item => {
      return columns.map(col => {
        const value = item[col.key]
        return formatValue(value, col.type)
      })
    })

    // Combinar encabezados y datos
    const wsData = [headers, ...rows]

    // Crear worksheet
    const ws = XLSX.utils.aoa_to_sheet(wsData)

    // Aplicar anchos de columna
    ws['!cols'] = columns.map(col => ({ wch: col.width || 15 }))

    return ws
  }

  /**
   * Exporta datos a un archivo Excel (.xlsx)
   * @param {Array} data - Array de objetos con los datos
   * @param {Array} columns - Definición de columnas [{header, key, type?, width?}]
   * @param {string} filename - Nombre del archivo (sin extensión)
   * @param {string} sheetName - Nombre de la hoja (default: 'Datos')
   */
  const exportToExcel = (data, columns, filename = 'export', sheetName = 'Datos') => {
    if (!data || data.length === 0) {
      console.warn('useExcelExport: No hay datos para exportar')
      return false
    }

    try {
      // Crear workbook
      const wb = XLSX.utils.book_new()

      // Crear worksheet con los datos
      const ws = dataToWorksheet(data, columns)

      // Agregar hoja al workbook
      XLSX.utils.book_append_sheet(wb, ws, sheetName)

      // Generar nombre de archivo con fecha
      const date = new Date().toISOString().split('T')[0]
      const fullFilename = `${filename}_${date}.xlsx`

      // Descargar archivo
      XLSX.writeFile(wb, fullFilename)

      return true
    } catch (error) {
      console.error('useExcelExport: Error al exportar', error)
      return false
    }
  }

  /**
   * Exporta múltiples hojas a un archivo Excel
   * @param {Array} sheets - Array de {name, data, columns}
   * @param {string} filename - Nombre del archivo (sin extensión)
   */
  const exportMultiSheet = (sheets, filename = 'export') => {
    if (!sheets || sheets.length === 0) {
      console.warn('useExcelExport: No hay hojas para exportar')
      return false
    }

    try {
      // Crear workbook
      const wb = XLSX.utils.book_new()

      // Agregar cada hoja
      sheets.forEach(sheet => {
        if (sheet.data && sheet.data.length > 0) {
          const ws = dataToWorksheet(sheet.data, sheet.columns)
          XLSX.utils.book_append_sheet(wb, ws, sheet.name || 'Hoja')
        }
      })

      // Verificar que haya al menos una hoja
      if (wb.SheetNames.length === 0) {
        console.warn('useExcelExport: Ninguna hoja tiene datos')
        return false
      }

      // Generar nombre de archivo con fecha
      const date = new Date().toISOString().split('T')[0]
      const fullFilename = `${filename}_${date}.xlsx`

      // Descargar archivo
      XLSX.writeFile(wb, fullFilename)

      return true
    } catch (error) {
      console.error('useExcelExport: Error al exportar múltiples hojas', error)
      return false
    }
  }

  /**
   * Exporta datos directamente desde un array de arrays (sin columnas definidas)
   * Útil para exportar datos raw o con encabezados personalizados
   * @param {Array} rows - Array de arrays con los datos (primera fila = encabezados)
   * @param {string} filename - Nombre del archivo
   * @param {string} sheetName - Nombre de la hoja
   */
  const exportRaw = (rows, filename = 'export', sheetName = 'Datos') => {
    if (!rows || rows.length === 0) {
      console.warn('useExcelExport: No hay datos para exportar')
      return false
    }

    try {
      const wb = XLSX.utils.book_new()
      const ws = XLSX.utils.aoa_to_sheet(rows)
      XLSX.utils.book_append_sheet(wb, ws, sheetName)

      const date = new Date().toISOString().split('T')[0]
      XLSX.writeFile(wb, `${filename}_${date}.xlsx`)

      return true
    } catch (error) {
      console.error('useExcelExport: Error al exportar raw', error)
      return false
    }
  }

  /**
   * Genera definición de columnas automática basada en los datos
   * @param {Array} data - Array de objetos
   * @param {Object} labelMap - Mapeo de keys a labels {key: 'Label'}
   * @returns {Array} Definición de columnas
   */
  const autoColumns = (data, labelMap = {}) => {
    if (!data || data.length === 0) return []

    const firstItem = data[0]
    return Object.keys(firstItem).map(key => ({
      header: labelMap[key] || key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase()),
      key: key,
      width: Math.max(15, (labelMap[key] || key).length + 5)
    }))
  }

  return {
    exportToExcel,
    exportMultiSheet,
    exportRaw,
    autoColumns,
    formatValue
  }
}
