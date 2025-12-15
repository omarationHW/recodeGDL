<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="search-plus" />
      </div>
      <div class="module-view-info">
        <h1>Consulta 2 - Búsqueda Avanzada</h1>
        <p>{{ tituloTabla }}</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-info"
          @click="cargarConfiguracion"
          :disabled="loading"
          title="Actualizar"
        >
          <font-awesome-icon icon="sync" :spin="loading" />
          Actualizar
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
        <button
          class="btn-municipal-secondary"
          @click="goBack"
          :disabled="loading"
        >
          <font-awesome-icon icon="arrow-left" />
          Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Tarjeta de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            {{ etiquetaBusqueda }}
          </h5>
        </div>

        <div class="municipal-card-body">
          <form @submit.prevent="buscarCoincidencias">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">
                  Criterio de Búsqueda <span class="required">*</span>
                </label>
                <select
                  class="municipal-form-control"
                  v-model.number="criterioBusqueda"
                  required
                >
                  <option :value="1">{{ etiquetas.etiq_control || 'Control/Etiqueta' }}</option>
                  <option :value="2">{{ etiquetas.concesionario || 'Concesionario' }}</option>
                  <option :value="3">{{ etiquetas.ubicacion || 'Ubicación' }}</option>
                  <option :value="4">{{ etiquetas.nombre_comercial || 'Nombre Comercial' }}</option>
                  <option :value="5">{{ etiquetas.lugar || 'Lugar' }}</option>
                  <option :value="6">{{ etiquetas.obs || 'Observaciones' }}</option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">
                  Dato a Buscar <span class="required">*</span>
                </label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="datoBusqueda"
                  placeholder="Escriba el dato a buscar..."
                  required
                >
              </div>
            </div>

            <div class="button-group">
              <button
                type="submit"
                class="btn-municipal-primary"
                :disabled="loading"
              >
                <font-awesome-icon icon="search" />
                {{ loading ? 'Buscando...' : 'Buscar Coincidencias' }}
              </button>
              <button
                type="button"
                class="btn-municipal-secondary"
                @click="limpiarFormulario"
                :disabled="loading"
              >
                <font-awesome-icon icon="eraser" />
                Limpiar
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Tarjeta de resultados de búsqueda (coincidencias) -->
      <div class="municipal-card" v-if="coincidencias.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Controles Encontrados ({{ coincidencias.length }} coincidencias)
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Control</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="(item, index) in coincidencias"
                  :key="index"
                  class="row-hover"
                  :class="{ 'selected-row': controlSeleccionado === item.control }"
                >
                  <td>{{ item.control }}</td>
                  <td class="text-center">
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click="seleccionarControl(item.control)"
                      :disabled="loading"
                    >
                      <font-awesome-icon icon="eye" />
                      Ver Detalle
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Navegador de coincidencias -->
          <div class="pagination-nav" v-if="coincidencias.length > 0">
            <button
              class="btn-municipal-secondary btn-sm"
              @click="navegarCoincidencia(-1)"
              :disabled="coincidenciaActualIndex === 0 || loading"
            >
              <font-awesome-icon icon="chevron-left" />
              Anterior
            </button>
            <span class="badge-purple">
              {{ coincidenciaActualIndex + 1 }} de {{ coincidencias.length }}
            </span>
            <button
              class="btn-municipal-secondary btn-sm"
              @click="navegarCoincidencia(1)"
              :disabled="coincidenciaActualIndex === coincidencias.length - 1 || loading"
            >
              Siguiente
              <font-awesome-icon icon="chevron-right" />
            </button>
          </div>
        </div>
      </div>

      <!-- Tarjeta de información del contrato -->
      <div class="municipal-card" v-if="datosContrato && !statusNoExiste">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="info-circle" />
            Información del Control: {{ datosContrato.control }}
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="info-grid">
            <div class="info-item">
              <label>{{ etiquetas.concesionario || 'Concesionario' }}:</label>
              <span>{{ datosContrato.concesionario }}</span>
            </div>
            <div class="info-item">
              <label>{{ etiquetas.ubicacion || 'Ubicación' }}:</label>
              <span>{{ datosContrato.ubicacion }}</span>
            </div>
            <div class="info-item" v-if="datosContrato.nomcomercial">
              <label>{{ etiquetas.nombre_comercial || 'Nombre Comercial' }}:</label>
              <span>{{ datosContrato.nomcomercial }}</span>
            </div>
            <div class="info-item" v-if="datosContrato.lugar">
              <label>{{ etiquetas.lugar || 'Lugar' }}:</label>
              <span>{{ datosContrato.lugar }}</span>
            </div>
            <div class="info-item" v-if="datosContrato.obs">
              <label>{{ etiquetas.obs || 'Observaciones' }}:</label>
              <span>{{ datosContrato.obs }}</span>
            </div>
            <div class="info-item" v-if="tipoTabla !== '5' && datosContrato.superficie">
              <label>{{ etiquetas.superficie || 'Superficie' }}:</label>
              <span>{{ datosContrato.superficie }} m²</span>
            </div>
            <div class="info-item" v-if="datosContrato.unidades">
              <label>{{ etiquetas.unidad || 'Unidades' }}:</label>
              <span>{{ datosContrato.unidades }}</span>
            </div>
            <div class="info-item" v-if="datosContrato.categoria">
              <label>{{ etiquetas.categoria || 'Categoría' }}:</label>
              <span>{{ datosContrato.categoria }}</span>
            </div>
            <div class="info-item" v-if="datosContrato.seccion">
              <label>{{ etiquetas.seccion || 'Sección' }}:</label>
              <span>{{ datosContrato.seccion }}</span>
            </div>
            <div class="info-item" v-if="datosContrato.bloque">
              <label>{{ etiquetas.bloque || 'Bloque' }}:</label>
              <span>{{ datosContrato.bloque }}</span>
            </div>
            <div class="info-item">
              <label>{{ etiquetas.fecha_inicio || 'Fecha Inicio' }}:</label>
              <span>{{ formatDate(datosContrato.fechainicio) }}</span>
            </div>
            <div class="info-item" v-if="datosContrato.fechafin">
              <label>{{ etiquetas.fecha_fin || 'Fecha Fin' }}:</label>
              <span>{{ formatDate(datosContrato.fechafin) }}</span>
            </div>
            <div class="info-item">
              <label>{{ etiquetas.recaudadora || 'Oficina' }}:</label>
              <span>{{ datosContrato.recaudadora }}</span>
            </div>
            <div class="info-item" v-if="datosContrato.sector">
              <label>{{ etiquetas.sector || 'Sector' }}:</label>
              <span>{{ datosContrato.sector }}</span>
            </div>
            <div class="info-item" v-if="datosContrato.zona">
              <label>{{ etiquetas.zona || 'Zona' }}:</label>
              <span>{{ datosContrato.zona }}</span>
            </div>
            <div class="info-item" v-if="datosContrato.licencia">
              <label>{{ etiquetas.licencia || 'Licencia' }}:</label>
              <span>{{ datosContrato.licencia }}</span>
            </div>
            <div class="info-item">
              <label>Status:</label>
              <span class="badge" :class="statusClass">{{ datosContrato.statusregistro }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Tarjeta de totales de adeudos -->
      <div class="municipal-card" v-if="adeudosTotales.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="calculator" />
            Totales de Adeudos por Concepto
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Concepto</th>
                  <th class="text-center">Periodos</th>
                  <th class="text-right">Importe Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(total, index) in adeudosTotales" :key="index" class="row-hover">
                  <td>{{ total.concepto }}</td>
                  <td class="text-center">{{ total.cuenta }}</td>
                  <td class="text-right font-weight-bold">{{ formatCurrency(total.importe) }}</td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td class="font-weight-bold" colspan="2">TOTAL A PAGAR:</td>
                  <td class="text-right font-weight-bold total-amount">
                    {{ formatCurrency(totalAPagar) }}
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Mensaje si hay Gastos o Multas -->
          <div v-if="tieneGastosOMultas" class="municipal-alert municipal-alert-warning">
            <font-awesome-icon icon="exclamation-triangle" />
            <strong>Nota:</strong> Existen conceptos de Gastos o Multas. Pueden consultarse en el módulo de Apremios.
          </div>
        </div>
      </div>

      <!-- Tarjeta de detalle de adeudos -->
      <div class="municipal-card" v-if="adeudosDetalle.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="calendar-alt" />
            Detalle de Adeudos por Periodo
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Concepto</th>
                  <th class="text-center">Año</th>
                  <th class="text-center">Mes</th>
                  <th class="text-right">Importe</th>
                  <th class="text-right">Recargos</th>
                  <th class="text-right">Dscto. Importe</th>
                  <th class="text-right">Dscto. Recargos</th>
                  <th class="text-right">Actualización</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(detalle, index) in adeudosDetalle" :key="index" class="row-hover">
                  <td>{{ detalle.concepto }}</td>
                  <td class="text-center">{{ detalle.axo }}</td>
                  <td class="text-center">{{ getNombreMes(detalle.mes) }}</td>
                  <td class="text-right">{{ formatCurrency(detalle.importe_pagar) }}</td>
                  <td class="text-right">{{ formatCurrency(detalle.recargos_pagar) }}</td>
                  <td class="text-right">{{ formatCurrency(detalle.dscto_importe) }}</td>
                  <td class="text-right">{{ formatCurrency(detalle.dscto_recargos) }}</td>
                  <td class="text-right">{{ formatCurrency(detalle.actualizacion_pagar) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Botones de acción adicionales -->
      <div class="municipal-card" v-if="datosContrato && !statusNoExiste">
        <div class="municipal-card-body">
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="verPagados"
              :disabled="loading || !tienePagados"
            >
              <font-awesome-icon icon="file-invoice-dollar" />
              Ver Pagados
            </button>
            <button
              class="btn-municipal-secondary"
              @click="verHistorico"
              :disabled="loading"
            >
              <font-awesome-icon icon="history" />
              Ver Histórico
            </button>
            <button
              class="btn-municipal-secondary"
              @click="verApremios"
              :disabled="loading || !tieneGastosOMultas"
            >
              <font-awesome-icon icon="gavel" />
              Ver Apremios
            </button>
          </div>
        </div>
      </div>

    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'GConsulta2'"
    :moduleName="'otras_obligaciones'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

// Router
const route = useRoute()
const router = useRouter()

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const BASE_DB = 'otras_obligaciones'
const { showLoading, hideLoading } = useGlobalLoading()
const {
  showToast,
  handleApiError
} = useLicenciasErrorHandler()

// Estado local de loading (para deshabilitar botones)
const loading = ref(false)

// Estado
const tipoTabla = ref(route.params.tabla || route.query.tabla || '1')
const etiquetas = ref({})
const infoTabla = ref({})
const criterioBusqueda = ref(1)
const datoBusqueda = ref('')
const coincidencias = ref([])
const coincidenciaActualIndex = ref(0)
const controlSeleccionado = ref('')
const datosContrato = ref(null)
const statusNoExiste = ref(false)
const adeudosTotales = ref([])
const adeudosDetalle = ref([])
const tienePagados = ref(false)

// Computed
const tituloTabla = computed(() => {
  if (infoTabla.value.nombre) {
    return `Consulta Avanzada de: ${infoTabla.value.nombre}`
  }
  return 'Otras Obligaciones - Consulta 2'
})

const etiquetaBusqueda = computed(() => {
  return etiquetas.value.etiq_control || 'Búsqueda Avanzada por Criterio'
})

const totalAPagar = computed(() => {
  return adeudosTotales.value.reduce((sum, item) => sum + (item.importe || 0), 0)
})

const tieneGastosOMultas = computed(() => {
  return adeudosTotales.value.some(item =>
    item.concepto && (
      item.concepto.toLowerCase().includes('gastos') ||
      item.concepto.toLowerCase().includes('multas')
    )
  )
})

const statusClass = computed(() => {
  if (!datosContrato.value) return ''
  const status = datosContrato.value.statusregistro
  if (status === 'VIGENTE') return 'badge-success'
  if (status === 'CANCELADO') return 'badge-danger'
  if (status === 'SUSPENSION') return 'badge-warning'
  return 'badge-secondary'
})

// Métodos
const cargarConfiguracion = async () => {
  loading.value = true
  showLoading('Cargando configuración...')

  try {
    // Cargar etiquetas
    const responseEtiq = await execute(
      'sp_gconsulta_get_etiquetas',
      BASE_DB,
      [{ nombre: 'par_tab', valor: tipoTabla.value, tipo: 'varchar' }],
      '',
      null,
      'publico'
    )

    if (responseEtiq && responseEtiq.result && responseEtiq.result.length > 0) {
      etiquetas.value = responseEtiq.result[0]
    }

    // Cargar información de la tabla
    const responseTabla = await execute(
      'sp_gconsulta_get_tabla_info',
      BASE_DB,
      [{ nombre: 'par_tab', valor: tipoTabla.value, tipo: 'varchar' }],
      '',
      null,
      'publico'
    )

    loading.value = false
    hideLoading()

    if (responseTabla && responseTabla.result && responseTabla.result.length > 0) {
      infoTabla.value = responseTabla.result[0]
    }

    showToast('success', 'Configuración cargada')

  } catch (error) {
    loading.value = false
    hideLoading()
    handleApiError(error)
  }
}

const buscarCoincidencias = async () => {
  if (!datoBusqueda.value.trim()) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'Debe ingresar un dato para buscar',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  loading.value = true
  showLoading('Buscando coincidencias...')

  try {
    const response = await execute(
      'sp_gconsulta2_buscar_coincidencias',
      BASE_DB,
      [
        { nombre: 'par_tab', valor: tipoTabla.value, tipo: 'varchar' },
        { nombre: 'par_tipo_busqueda', valor: criterioBusqueda.value, tipo: 'integer' },
        { nombre: 'par_dato', valor: datoBusqueda.value, tipo: 'varchar' }
      ],
      '',
      null,
      'publico'
    )

    loading.value = false
    hideLoading()

    if (response && response.result && response.result.length > 0) {
      coincidencias.value = response.result
      coincidenciaActualIndex.value = 0
      controlSeleccionado.value = ''

      // Si solo hay una coincidencia, seleccionarla automáticamente
      if (coincidencias.value.length === 1) {
        showToast('success', '1 coincidencia encontrada')
        await seleccionarControl(coincidencias.value[0].control)
      } else {
        showToast('success', `${coincidencias.value.length} coincidencias encontradas`)
      }
    } else {
      coincidencias.value = []
      await Swal.fire({
        icon: 'info',
        title: 'Sin resultados',
        text: 'No se encontraron registros que coincidan con el criterio de búsqueda',
        confirmButtonColor: '#ea8215'
      })
    }

  } catch (error) {
    loading.value = false
    hideLoading()
    handleApiError(error)
    coincidencias.value = []
  }
}

const navegarCoincidencia = async (direccion) => {
  const nuevoIndex = coincidenciaActualIndex.value + direccion
  if (nuevoIndex >= 0 && nuevoIndex < coincidencias.value.length) {
    coincidenciaActualIndex.value = nuevoIndex
    await seleccionarControl(coincidencias.value[nuevoIndex].control)
  }
}

const seleccionarControl = async (control) => {
  controlSeleccionado.value = control
  loading.value = true
  showLoading('Cargando datos del control...')

  try {
    // Buscar datos del contrato
    const responseDatos = await execute(
      'sp_gconsulta2_buscar_contrato',
      BASE_DB,
      [
        { nombre: 'par_tab', valor: tipoTabla.value, tipo: 'varchar' },
        { nombre: 'par_control', valor: control, tipo: 'varchar' }
      ],
      '',
      null,
      'publico'
    )

    if (!responseDatos || !responseDatos.result || responseDatos.result[0]?.status === 1) {
      loading.value = false
      hideLoading()
      statusNoExiste.value = true
      datosContrato.value = null
      await Swal.fire({
        icon: 'error',
        title: 'No encontrado',
        text: 'No existe REGISTRO ALGUNO con este dato, inténtalo de nuevo',
        confirmButtonColor: '#ea8215'
      })
      return
    }

    statusNoExiste.value = false
    datosContrato.value = responseDatos.result[0]

    // Verificar status del registro
    if (datosContrato.value.statusregistro !== 'VIGENTE') {
      loading.value = false
      hideLoading()
      await Swal.fire({
        icon: 'warning',
        title: 'Advertencia',
        text: 'LOCAL EN SUSPENSION O CANCELADO',
        confirmButtonColor: '#ea8215'
      })
      loading.value = true
      showLoading('Cargando adeudos...')
    }

    // Cargar adeudos
    await cargarAdeudos()

    loading.value = false
    hideLoading()
    showToast('success', 'Datos del control cargados')

  } catch (error) {
    loading.value = false
    hideLoading()
    handleApiError(error)
    statusNoExiste.value = true
    datosContrato.value = null
    adeudosTotales.value = []
    adeudosDetalle.value = []
  }
}

const cargarAdeudos = async () => {
  if (!datosContrato.value) return

  const now = new Date()
  const anoActual = now.getFullYear()
  const mesActual = 12 // Diciembre como en el código Delphi

  try {
    // Cargar totales
    const responseTotales = await execute(
      'sp_gconsulta2_get_totales',
      BASE_DB,
      [
        { nombre: 'par_tabla', valor: tipoTabla.value, tipo: 'varchar' },
        { nombre: 'par_id_datos', valor: datosContrato.value.id_datos, tipo: 'integer' },
        { nombre: 'par_ano', valor: anoActual, tipo: 'integer' },
        { nombre: 'par_mes', valor: mesActual, tipo: 'integer' }
      ],
      '',
      null,
      'publico'
    )

    if (responseTotales && responseTotales.result) {
      adeudosTotales.value = responseTotales.result.filter(r => r.concepto)
    } else {
      adeudosTotales.value = []
    }

    // Cargar detalle
    const responseDetalle = await execute(
      'sp_gconsulta2_get_detalle',
      BASE_DB,
      [
        { nombre: 'par_tabla', valor: tipoTabla.value, tipo: 'varchar' },
        { nombre: 'par_id_datos', valor: datosContrato.value.id_datos, tipo: 'integer' },
        { nombre: 'par_ano', valor: anoActual, tipo: 'integer' },
        { nombre: 'par_mes', valor: mesActual, tipo: 'integer' }
      ],
      '',
      null,
      'publico'
    )

    if (responseDetalle && responseDetalle.result) {
      adeudosDetalle.value = responseDetalle.result.filter(r => r.concepto)
    } else {
      adeudosDetalle.value = []
    }

    // Verificar si hay pagados
    const responsePagados = await execute(
      'sp_gconsulta_get_pagados',
      BASE_DB,
      [{ nombre: 'p_id_datos', valor: datosContrato.value.id_datos, tipo: 'integer' }],
      '',
      null,
      'publico'
    )

    tienePagados.value = responsePagados && responsePagados.result && responsePagados.result.length > 0

  } catch (error) {
    console.error('Error al cargar adeudos:', error)
    adeudosTotales.value = []
    adeudosDetalle.value = []
  }
}

const verPagados = async () => {
  if (!datosContrato.value) return

  loading.value = true
  showLoading('Cargando pagos realizados...')

  try {
    const response = await execute(
      'sp_gconsulta_get_pagados',
      BASE_DB,
      [{ nombre: 'p_id_datos', valor: datosContrato.value.id_datos, tipo: 'integer' }],
      '',
      null,
      'publico'
    )

    loading.value = false
    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const pagos = response.result

      // Calcular totales
      const totalImporte = pagos.reduce((sum, p) => sum + (p.importe || 0), 0)
      const totalRecargo = pagos.reduce((sum, p) => sum + (p.recargo || 0), 0)

      // Construir tabla HTML
      let tablaHtml = `
        <div style="max-height: 400px; overflow-y: auto;">
          <table style="width: 100%; border-collapse: collapse; font-size: 13px;">
            <thead>
              <tr style="background: #ea8215; color: white;">
                <th style="padding: 8px; text-align: left;">Fecha/Hora</th>
                <th style="padding: 8px; text-align: left;">Periodo</th>
                <th style="padding: 8px; text-align: right;">Importe</th>
                <th style="padding: 8px; text-align: right;">Recargo</th>
                <th style="padding: 8px; text-align: left;">Recibo</th>
              </tr>
            </thead>
            <tbody>
      `

      pagos.forEach((pago, index) => {
        const bgColor = index % 2 === 0 ? '#fff' : '#f8f9fa'
        tablaHtml += `
          <tr style="background: ${bgColor};">
            <td style="padding: 6px 8px;">${formatDateTime(pago.fecha_hora_pago)}</td>
            <td style="padding: 6px 8px;">${formatDate(pago.periodo)}</td>
            <td style="padding: 6px 8px; text-align: right;">${formatCurrency(pago.importe)}</td>
            <td style="padding: 6px 8px; text-align: right;">${formatCurrency(pago.recargo)}</td>
            <td style="padding: 6px 8px;">${pago.folio_recibo || 'S/N'}</td>
          </tr>
        `
      })

      tablaHtml += `
            </tbody>
            <tfoot>
              <tr style="background: #343a40; color: white; font-weight: bold;">
                <td colspan="2" style="padding: 8px;">TOTAL:</td>
                <td style="padding: 8px; text-align: right;">${formatCurrency(totalImporte)}</td>
                <td style="padding: 8px; text-align: right;">${formatCurrency(totalRecargo)}</td>
                <td style="padding: 8px;"></td>
              </tr>
            </tfoot>
          </table>
        </div>
      `

      await Swal.fire({
        title: '💰 Pagos Realizados',
        html: tablaHtml,
        width: '800px',
        confirmButtonColor: '#ea8215',
        confirmButtonText: 'Cerrar'
      })
    } else {
      await Swal.fire({
        icon: 'info',
        title: 'Sin pagos',
        text: 'No se encontraron pagos realizados para este registro',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    loading.value = false
    hideLoading()
    handleApiError(error)
  }
}

const verHistorico = async () => {
  if (!datosContrato.value) return

  loading.value = true
  showLoading('Cargando histórico...')

  try {
    const response = await execute(
      'sp_gconsulta_get_historico',
      BASE_DB,
      [{ nombre: 'p_id_datos', valor: datosContrato.value.id_datos, tipo: 'integer' }],
      '',
      null,
      'publico'
    )

    loading.value = false
    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const movimientos = response.result

      // Construir tabla HTML
      let tablaHtml = `
        <div style="max-height: 400px; overflow-y: auto;">
          <table style="width: 100%; border-collapse: collapse; font-size: 13px;">
            <thead>
              <tr style="background: #6f42c1; color: white;">
                <th style="padding: 8px; text-align: left;">Fecha</th>
                <th style="padding: 8px; text-align: center;">Tipo</th>
                <th style="padding: 8px; text-align: left;">Descripción</th>
                <th style="padding: 8px; text-align: right;">Importe</th>
              </tr>
            </thead>
            <tbody>
      `

      movimientos.forEach((mov, index) => {
        const bgColor = index % 2 === 0 ? '#fff' : '#f8f9fa'
        const tipoBadge = mov.tipo_movimiento === 'PAGO'
          ? '<span style="background: #28a745; color: white; padding: 2px 8px; border-radius: 4px; font-size: 11px;">PAGO</span>'
          : '<span style="background: #17a2b8; color: white; padding: 2px 8px; border-radius: 4px; font-size: 11px;">ADEUDO</span>'

        tablaHtml += `
          <tr style="background: ${bgColor};">
            <td style="padding: 6px 8px;">${formatDateTime(mov.fecha)}</td>
            <td style="padding: 6px 8px; text-align: center;">${tipoBadge}</td>
            <td style="padding: 6px 8px;">${mov.descripcion}</td>
            <td style="padding: 6px 8px; text-align: right;">${formatCurrency(mov.importe)}</td>
          </tr>
        `
      })

      tablaHtml += `
            </tbody>
          </table>
        </div>
        <p style="margin-top: 10px; font-size: 12px; color: #666;">
          Total de movimientos: <strong>${movimientos.length}</strong>
        </p>
      `

      await Swal.fire({
        title: '📋 Histórico de Movimientos',
        html: tablaHtml,
        width: '850px',
        confirmButtonColor: '#ea8215',
        confirmButtonText: 'Cerrar'
      })
    } else {
      await Swal.fire({
        icon: 'info',
        title: 'Sin histórico',
        text: 'No se encontraron movimientos en el histórico para este registro',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    loading.value = false
    hideLoading()
    handleApiError(error)
  }
}

const verApremios = async () => {
  await Swal.fire({
    icon: 'info',
    title: 'Apremios',
    text: 'La funcionalidad de apremios estará disponible próximamente',
    confirmButtonColor: '#ea8215'
  })
}

const limpiarFormulario = () => {
  datoBusqueda.value = ''
  coincidencias.value = []
  coincidenciaActualIndex.value = 0
  controlSeleccionado.value = ''
  datosContrato.value = null
  statusNoExiste.value = false
  adeudosTotales.value = []
  adeudosDetalle.value = []
  tienePagados.value = false
}

const goBack = () => {
  router.push('/otras_obligaciones')
}

// Utilidades
const formatDate = (dateString) => {
  if (!dateString) return ''
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-MX', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch (error) {
    return dateString
  }
}

const formatDateTime = (dateTimeString) => {
  if (!dateTimeString) return ''
  try {
    const date = new Date(dateTimeString)
    return date.toLocaleString('es-MX', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch (error) {
    return dateTimeString
  }
}

const formatCurrency = (value) => {
  if (!value && value !== 0) return '$0.00'
  try {
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN'
    }).format(value)
  } catch (error) {
    return `$${value}`
  }
}

const getNombreMes = (mes) => {
  const meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ]
  return meses[mes - 1] || mes
}

// Lifecycle
onMounted(() => {
  cargarConfiguracion()
})
</script>
