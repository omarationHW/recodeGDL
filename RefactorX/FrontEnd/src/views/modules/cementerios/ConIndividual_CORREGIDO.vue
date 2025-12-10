<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-alt" />
      </div>
      <div class="module-view-info">
        <h1>Consulta Individual de Folios</h1>
        <p>Cementerios - Consulta detallada de folios y pagos</p>
      </div>
      <div class="button-group ms-auto">
        <button
          v-if="folio"
          class="btn-municipal-secondary"
          @click="limpiar"
        >
          <font-awesome-icon icon="eraser" />
          Limpiar
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Búsqueda de Folio -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Buscar Folio
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Número de Folio</label>
              <input
                v-model.number="folioABuscar"
                type="number"
                class="municipal-form-control"
                placeholder="Ingrese número de folio"
                @keyup.enter="buscarFolio"
                min="1"
              />
            </div>
          </div>
          <div class="button-group">
            <button @click="buscarFolio" class="btn-municipal-primary">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button @click="limpiar" class="btn-municipal-secondary">
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Datos del Folio -->
      <div v-if="folio" class="municipal-card">
        <div class="municipal-card-header">
          <div class="header-with-badge">
            <h5>
              <font-awesome-icon icon="info-circle" />
              Información del Folio
            </h5>
            <span class="badge-purple">{{ folio.control_rcm }}</span>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="info-sections">
            <!-- Datos del Titular -->
            <div class="info-section">
              <h3 class="section-title">
                <font-awesome-icon icon="user" />
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
                <font-awesome-icon icon="map-marker-alt" />
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
                <font-awesome-icon icon="calendar-check" />
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
                <font-awesome-icon icon="comment" />
                Observaciones
              </h3>
              <p class="observaciones-text">{{ folio.observaciones }}</p>
            </div>

            <!-- Última Actualización -->
            <div class="info-section">
              <h3 class="section-title">
                <font-awesome-icon icon="clock" />
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
      <div v-if="folio && pagos.length > 0" class="municipal-card">
        <div class="municipal-card-header">
          <div class="header-with-badge">
            <h5>
              <font-awesome-icon icon="money-bill-wave" />
              Historial de Pagos
            </h5>
            <span class="badge-success">{{ pagos.length }} registros</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
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

      <!-- Mensaje cuando no hay resultados -->
      <div v-if="busquedaRealizada && !folio" class="alert alert-warning">
        <font-awesome-icon icon="exclamation-triangle" />
        <strong>No se encontró el folio especificado</strong>
        <p class="mb-0">
          <small>Verifique el número de folio e intente nuevamente</small>
        </p>
      </div>
    </div>
  </div>

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'ConIndividual'"
    :moduleName="'cementerios'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useToast } from '@/composables/useToast'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

// ✅ CORRECCIÓN: Usar execute en lugar de api.callStoredProcedure
const { execute } = useApi()
const toast = useToast()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const showDocumentation = ref(false)
const folioABuscar = ref(null)
const folio = ref(null)
const pagos = ref([])
const busquedaRealizada = ref(false)

// Métodos de documentación
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

// ✅ CORRECCIÓN: Función buscarFolio con nuevo formato de llamada
const buscarFolio = async () => {
  if (!folioABuscar.value || folioABuscar.value <= 0) {
    toast.warning('Ingrese un número de folio válido')
    return
  }

  showLoading('Buscando folio...', 'Consultando base de datos')
  busquedaRealizada.value = true

  try {
    // ✅ NUEVO FORMATO: Array de parámetros con estructura {nombre, valor, tipo}
    const params = [
      {
        nombre: 'p_control_rcm',
        valor: folioABuscar.value,
        tipo: 'integer'
      }
    ]

    // ✅ NUEVO FORMATO: Llamada con execute()
    const response = await execute(
      'sp_cem_consultar_folio',  // Nombre del SP (lowercase)
      'cementerio',              // Módulo
      params,                     // Parámetros con estructura
      'cementerio',              // Conexión
      null,                       // Parámetro adicional
      'public'                    // Schema de PostgreSQL
    )

    hideLoading()

    // ✅ CORRECCIÓN: Los datos están en response.result (no response.data)
    if (response && response.result && response.result.length > 0) {
      const result = response.result[0]

      if (result.resultado === 'N') {
        folio.value = null
        pagos.value = []
        toast.warning(result.mensaje || 'No se encontró el folio')
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
    hideLoading()
    console.error('Error al buscar folio:', error)
    toast.error('Error al buscar folio: ' + (error.message || 'Error desconocido'))
    folio.value = null
    pagos.value = []
  }
}

// ✅ CORRECCIÓN: Función cargarPagos con nuevo formato
const cargarPagos = async () => {
  try {
    const params = [
      {
        nombre: 'p_control_rcm',
        valor: folioABuscar.value,
        tipo: 'integer'
      }
    ]

    const response = await execute('sp_cem_consultar_pagos_folio', 'cementerios', params,
      'cementerios',
      null,
      'public'
    , '', null, 'comun')

    // ✅ CORRECCIÓN: Usar response.result
    pagos.value = response.result && response.result ? response.result : []
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
/* Estilos únicos de secciones de información - Justificado mantener scoped */
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
