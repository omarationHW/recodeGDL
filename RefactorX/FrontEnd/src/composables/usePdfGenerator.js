/**
 * Composable wrapper para compatibilidad con código existente
 * Re-exporta funciones de usePdfExport con nombres alternativos
 */
import { usePdfExport } from './usePdfExport'

export function usePdfGenerator() {
  const { exportToPdf, generatePreview, printDirect, generateDocument, formatValue } = usePdfExport()

  // Alias para compatibilidad
  const verReporteTabular = (data, options) => generatePreview(data, options)
  const descargarReporteTabular = (data, options) => exportToPdf(data, options)
  const verPDF = (data, options) => generatePreview(data, options)
  const descargarPDF = (data, options) => exportToPdf(data, options)

  return {
    // Funciones originales
    exportToPdf,
    generatePreview,
    printDirect,
    generateDocument,
    formatValue,
    // Alias para compatibilidad
    verReporteTabular,
    descargarReporteTabular,
    verPDF,
    descargarPDF
  }
}
