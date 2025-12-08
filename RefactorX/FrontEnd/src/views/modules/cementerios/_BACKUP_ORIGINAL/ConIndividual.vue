<template>
  <div class="module-container">
    <div class="module-header">
      <h1 class="module-title">
        <i class="fas fa-file-alt"></i>
        Consulta Individual de Folios
      </h1>
      <DocumentationModal
        title="Ayuda - Consulta Individual"
        :sections="helpSections"
      />
    </div>

    <!-- Búsqueda de Folio -->
    <div class="card mb-3">
      <div class="card-header">
        <i class="fas fa-search"></i>
        Buscar Folio
      </div>
      <div class="card-body">
        <div class="form-grid-three">
          <div class="form-group">
            <label class="form-label required">Número de Folio</label>
            <input
              v-model.number="folioABuscar"
              type="number"
              class="form-control"
              placeholder="Ingrese número de folio"
              @keyup.enter="buscarFolio"
              min="1"
            />
          </div>
          <div class="form-actions">
            <button @click="buscarFolio" class="btn-municipal-primary">
              <i class="fas fa-search"></i>
              Buscar
            </button>
            <button @click="limpiar" class="btn-municipal-secondary">
              <i class="fas fa-eraser"></i>
              Limpiar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Datos del Folio -->
    <div v-if="folio" class="card mb-3">
      <div class="card-header">
        <i class="fas fa-info-circle"></i>
        Información del Folio {{ folio.control_rcm }}
      </div>
      <div class="card-body">
        <div class="info-sections">
          <!-- Datos del Titular -->
          <div class="info-section">
            <h3 class="section-title">
              <i class="fas fa-user"></i>
              Datos del Titular
            </h3>
            <div class="info-grid">
              <div class="info-item">
                <span class="info-label">Nombre:</span>
                <span class="info-value">{{ folio.nombre }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Domicilio:</span>
                <span class="info-value">{{ formatearDomicilio(folio) }}</span>
              </div>
            </div>
          </div>

          <!-- Ubicación -->
          <div class="info-section">
            <h3 class="section-title">
              <i class="fas fa-map-marker-alt"></i>
              Ubicación
            </h3>
            <div class="info-grid">
              <div class="info-item">
                <span class="info-label">Cementerio:</span>
                <span class="info-value">{{ folio.cementerio_nombre || folio.cementerio }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Clase:</span>
                <span class="info-value">{{ folio.clase }}{{ folio.clase_alfa || '' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Sección:</span>
                <span class="info-value">{{ folio.seccion }}{{ folio.seccion_alfa || '' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Línea:</span>
                <span class="info-value">{{ folio.linea }}{{ folio.linea_alfa || '' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Fosa:</span>
                <span class="info-value">{{ folio.fosa }}{{ folio.fosa_alfa || '' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Metros:</span>
                <span class="info-value">{{ folio.metros }} m²</span>
              </div>
            </div>
          </div>

          <!-- Estado de Pago -->
          <div class="info-section">
            <h3 class="section-title">
              <i class="fas fa-calendar-check"></i>
              Estado de Pago
            </h3>
            <div class="info-grid">
              <div class="info-item">
                <span class="info-label">Año Pagado:</span>
                <span class="info-value highlight-year">{{ folio.axo_pagado }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Estado:</span>
                <span :class="getEstadoPagoClass()">{{ getEstadoPago() }}</span>
              </div>
            </div>
          </div>

          <!-- Observaciones -->
          <div v-if="folio.observaciones" class="info-section">
            <h3 class="section-title">
              <i class="fas fa-comment"></i>
              Observaciones
            </h3>
            <p class="observaciones-text">{{ folio.observaciones }}</p>
          </div>

          <!-- Última Actualización -->
          <div class="info-section">
            <h3 class="section-title">
              <i class="fas fa-clock"></i>
              Última Actualización
            </h3>
            <div class="info-grid">
              <div class="info-item">
                <span class="info-label">Usuario:</span>
                <span class="info-value">{{ folio.usuario }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Fecha:</span>
                <span class="info-value">{{ formatearFecha(folio.fecha_mov) }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Historial de Pagos -->
    <div v-if="folio && pagos.length > 0" class="card">
      <div class="card-header">
        <i class="fas fa-money-bill-wave"></i>
        Historial de Pagos ({{ pagos.length }})
      </div>
      <div class="card-body">
        <div class="table-responsive">
          <table class="data-table">
            <thead>
              <tr>
                <th>Año</th>
                <th>Fecha</th>
                <th>Recibo</th>
                <th>Importe</th>
                <th>Descuento</th>
                <th>Bonificación</th>
                <th>Recargo</th>
                <th>Total</th>
                <th>Usuario</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="pago in pagos" :key="`${pago.anio}-${pago.recibo}`">
                <td>{{ pago.anio }}</td>
                <td>{{ formatearFecha(pago.fecha_mov) }}</td>
                <td>{{ pago.recibo }}</td>
                <td>${{ formatearMoneda(pago.importe) }}</td>
                <td>${{ formatearMoneda(pago.descuento) }}</td>
                <td>${{ formatearMoneda(pago.bonificacion) }}</td>
                <td>${{ formatearMoneda(pago.recargo) }}</td>
                <td class="total-amount">${{ formatearMoneda(pago.total) }}</td>
                <td>{{ pago.nombre_usuario || pago.usuario }}</td>
              </tr>
            </tbody>
            <tfoot>
              <tr class="totals-row">
                <td colspan="3"><strong>Totales:</strong></td>
                <td><strong>${{ formatearMoneda(calcularTotalImportes()) }}</strong></td>
                <td><strong>${{ formatearMoneda(calcularTotalDescuentos()) }}</strong></td>
                <td><strong>${{ formatearMoneda(calcularTotalBonificaciones()) }}</strong></td>
                <td><strong>${{ formatearMoneda(calcularTotalRecargos()) }}</strong></td>
                <td class="total-amount"><strong>${{ formatearMoneda(calcularTotalGeneral()) }}</strong></td>
                <td></td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </div>

    <div v-else-if="busquedaRealizada && !folio" class="alert-warning">
      <i class="fas fa-exclamation-triangle"></i>
      No se encontró el folio especificado
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const api = useApi()
const toast = useToast()

const folioABuscar = ref(null)
const folio = ref(null)
const pagos = ref([])
const busquedaRealizada = ref(false)

const helpSections = [
  {
    title: 'Consulta Individual de Folios',
    content: `
      <p>Este módulo permite consultar toda la información de un folio específico.</p>
      <h4>Información Mostrada:</h4>
      <ul>
        <li><strong>Datos del Titular:</strong> Nombre y domicilio completo</li>
        <li><strong>Ubicación:</strong> Cementerio, clase, sección, línea, fosa y metros</li>
        <li><strong>Estado de Pago:</strong> Año pagado y estado actual</li>
        <li><strong>Historial de Pagos:</strong> Todos los pagos registrados con detalle</li>
      </ul>
      <h4>Uso:</h4>
      <ol>
        <li>Ingrese el número de folio a consultar</li>
        <li>Presione Enter o haga clic en "Buscar"</li>
        <li>Revise la información completa del folio</li>
        <li>Consulte el historial de pagos en la tabla inferior</li>
      </ol>
    `
  }
]

const buscarFolio = async () => {
  if (!folioABuscar.value || folioABuscar.value <= 0) {
    toast.warning('Ingrese un número de folio válido')
    return
  }

  try {
    // Consultar datos del folio
    const response = await api.callStoredProcedure('SP_CEM_CONSULTAR_FOLIO', {
      p_control_rcm: folioABuscar.value
    })

    busquedaRealizada.value = true

    if (response.data && response.data.length > 0) {
      const result = response.data[0]

      if (result.resultado === 'N') {
        folio.value = null
        pagos.value = []
        toast.warning(result.mensaje)
        return
      }

      folio.value = result
      toast.success('Folio encontrado')

      // Consultar pagos del folio
      await cargarPagos()
    } else {
      folio.value = null
      pagos.value = []
      toast.warning('No se encontró el folio')
    }
  } catch (error) {
    console.error('Error al buscar folio:', error)
    toast.error('Error al buscar folio')
    folio.value = null
    pagos.value = []
  }
}

const cargarPagos = async () => {
  try {
    const response = await api.callStoredProcedure('SP_CEM_CONSULTAR_PAGOS_FOLIO', {
      p_control_rcm: folioABuscar.value
    })

    pagos.value = response.data || []
  } catch (error) {
    console.error('Error al cargar pagos:', error)
    toast.error('Error al cargar historial de pagos')
    pagos.value = []
  }
}

const limpiar = () => {
  folioABuscar.value = null
  folio.value = null
  pagos.value = []
  busquedaRealizada.value = false
}

const formatearDomicilio = (folio) => {
  const partes = [folio.domicilio]
  if (folio.exterior) partes.push(`#${folio.exterior}`)
  if (folio.interior) partes.push(`Int.${folio.interior}`)
  if (folio.colonia) partes.push(folio.colonia)
  return partes.filter(p => p).join(', ')
}

const formatearFecha = (fecha) => {
  if (!fecha) return '-'
  const date = new Date(fecha)
  return date.toLocaleDateString('es-MX')
}

const formatearMoneda = (valor) => {
  if (!valor) return '0.00'
  return parseFloat(valor).toFixed(2)
}

const getEstadoPago = () => {
  if (!folio.value) return ''
  const anioActual = new Date().getFullYear()
  const anioPagado = folio.value.axo_pagado

  if (anioPagado >= anioActual) {
    return 'Al Corriente'
  } else if (anioActual - anioPagado === 1) {
    return 'Atrasado 1 año'
  } else {
    return `Atrasado ${anioActual - anioPagado} años`
  }
}

const getEstadoPagoClass = () => {
  if (!folio.value) return ''
  const anioActual = new Date().getFullYear()
  const anioPagado = folio.value.axo_pagado

  if (anioPagado >= anioActual) {
    return 'estado-corriente'
  } else if (anioActual - anioPagado === 1) {
    return 'estado-advertencia'
  } else {
    return 'estado-atrasado'
  }
}

const calcularTotalImportes = () => {
  return pagos.value.reduce((sum, pago) => sum + parseFloat(pago.importe || 0), 0)
}

const calcularTotalDescuentos = () => {
  return pagos.value.reduce((sum, pago) => sum + parseFloat(pago.descuento || 0), 0)
}

const calcularTotalBonificaciones = () => {
  return pagos.value.reduce((sum, pago) => sum + parseFloat(pago.bonificacion || 0), 0)
}

const calcularTotalRecargos = () => {
  return pagos.value.reduce((sum, pago) => sum + parseFloat(pago.recargo || 0), 0)
}

const calcularTotalGeneral = () => {
  return pagos.value.reduce((sum, pago) => sum + parseFloat(pago.total || 0), 0)
}
</script>

<style scoped>
.info-sections {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.info-section {
  border-left: 3px solid var(--color-primary);
  padding-left: 1rem;
}

.section-title {
  font-size: 1.1rem;
  font-weight: 600;
  margin-bottom: 1rem;
  color: var(--color-primary);
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.info-label {
  font-size: 0.875rem;
  color: var(--color-text-secondary);
  font-weight: 500;
}

.info-value {
  font-size: 1rem;
  color: var(--color-text-primary);
}

.highlight-year {
  font-size: 1.5rem;
  font-weight: bold;
  color: var(--color-primary);
}

.estado-corriente {
  color: var(--color-success);
  font-weight: bold;
  font-size: 1rem;
}

.estado-advertencia {
  color: var(--color-warning);
  font-weight: bold;
  font-size: 1rem;
}

.estado-atrasado {
  color: var(--color-danger);
  font-weight: bold;
  font-size: 1rem;
}

.observaciones-text {
  padding: 1rem;
  background-color: var(--color-bg-secondary);
  border-radius: 0.375rem;
  margin: 0;
  font-style: italic;
}

.total-amount {
  font-weight: bold;
  color: var(--color-primary);
}

.totals-row {
  background-color: var(--color-bg-secondary);
  font-weight: bold;
}

.totals-row td {
  border-top: 2px solid var(--color-border);
}

@media (max-width: 768px) {
  .info-grid {
    grid-template-columns: 1fr;
  }
}
</style>
