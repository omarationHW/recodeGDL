<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="dollar-sign" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Pagos por Mercado</h1>
        <p>Mercados - Consulta de pagos realizados por local en mercados municipales</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Búsqueda
          </h5>
        </div>
        <div class="municipal-card-body">
        <form @submit.prevent="buscarPagos">
          <div class="form-row-municipal">
            <div class="form-group-municipal" style="flex: 0 0 25%;">
              <label class="form-label-municipal">Oficina Recaudadora</label>
              <select
                v-model="form.recaudadora_id"
                class="form-control-municipal"
                @change="onRecaudadoraChange"
                required
              >
                <option value="">Seleccione...</option>
                <option
                  v-for="rec in recaudadoras"
                  :key="rec.id_rec"
                  :value="rec.id_rec"
                >
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>

            <div class="form-group-municipal" style="flex: 0 0 35%;">
              <label class="form-label-municipal">Mercado</label>
              <select
                v-model="form.mercado_id"
                class="form-control-municipal"
                :disabled="!form.recaudadora_id"
                required
              >
                <option value="">Seleccione...</option>
                <option
                  v-for="merc in mercados"
                  :key="merc.num_mercado_nvo"
                  :value="merc.num_mercado_nvo"
                >
                  {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>

            <div class="form-group-municipal" style="flex: 0 0 20%;">
              <label class="form-label-municipal">Fecha Desde</label>
              <input
                type="date"
                v-model="form.fecha_desde"
                class="form-control-municipal"
                required
              />
            </div>

            <div class="form-group-municipal" style="flex: 0 0 20%;">
              <label class="form-label-municipal">Fecha Hasta</label>
              <input
                type="date"
                v-model="form.fecha_hasta"
                class="form-control-municipal"
                required
              />
            </div>
          </div>

          <div class="form-actions-municipal">
            <button
              type="submit"
              class="btn-primary-municipal"
              :disabled="loading"
            >
              <span v-if="loading">Buscando...</span>
              <span v-else>Buscar Pagos</span>
            </button>
            <button
              type="button"
              class="btn-success-municipal"
              @click="exportarExcel"
              :disabled="pagos.length === 0 || loading"
            >
              Exportar a Excel
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Resultados -->
    <div v-if="pagos.length > 0" class="card-municipal mt-3">
      <div class="card-header-municipal">
        <h3 class="card-title-municipal">
          Resultados de Búsqueda
          <span class="badge-municipal">{{ pagos.length }} registros</span>
        </h3>
      </div>
      <div class="card-body-municipal">
        <div class="table-container-municipal">
          <table class="table-municipal">
            <thead>
              <tr>
                <th>Mercado</th>
                <th>Sección</th>
                <th>Local</th>
                <th>Letra</th>
                <th>Bloque</th>
                <th>Año</th>
                <th>Mes</th>
                <th>Fecha Pago</th>
                <th>Rec.</th>
                <th>Caja</th>
                <th>Operación</th>
                <th>Renta Pagada</th>
                <th>Recibo</th>
                <th>Fecha Mov.</th>
                <th>Usuario</th>
                <th>Fecha Req.</th>
                <th>Folio Req.</th>
                <th>Periodos Req.</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(row, idx) in pagos" :key="`pago-${idx}`">
                <td>{{ row.num_mercado }}</td>
                <td>{{ row.seccion }}</td>
                <td>{{ row.local }}</td>
                <td>{{ row.letra_local || '-' }}</td>
                <td>{{ row.bloque || '-' }}</td>
                <td>{{ row.axo }}</td>
                <td>{{ row.periodo }}</td>
                <td>{{ formatDate(row.fecha_pago) }}</td>
                <td>{{ row.oficina_pago }}</td>
                <td>{{ row.caja_pago }}</td>
                <td>{{ row.operacion_pago }}</td>
                <td class="text-right-municipal">{{ formatCurrency(row.importe_pago) }}</td>
                <td>{{ row.folio }}</td>
                <td>{{ row.fecha_modificacion }}</td>
                <td>{{ row.usuario }}</td>
                <td>{{ formatDate(row.fecha_emision) }}</td>
                <td>{{ row.folio_1 || '-' }}</td>
                <td>{{ row.requerimientos || '-' }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Estado de carga o sin resultados -->
    <div v-else-if="!loading && searchExecuted" class="alert-info-municipal">
      No se encontraron pagos con los criterios especificados
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { useToast } from 'vue-toastification'

const toast = useToast()

// Estado reactivo
const recaudadoras = ref([])
const mercados = ref([])
const pagos = ref([])
const loading = ref(false)
const searchExecuted = ref(false)

const form = ref({
  recaudadora_id: '',
  mercado_id: '',
  fecha_desde: '',
  fecha_hasta: ''
})

// Inicializar fechas con el mes actual
onMounted(() => {
  const today = new Date()
  const firstDay = new Date(today.getFullYear(), today.getMonth(), 1)
  const lastDay = new Date(today.getFullYear(), today.getMonth() + 1, 0)

  form.value.fecha_desde = firstDay.toISOString().split('T')[0]
  form.value.fecha_hasta = lastDay.toISOString().split('T')[0]

  fetchRecaudadoras()
})

// Cargar catálogo de recaudadoras
const fetchRecaudadoras = async () => {
  loading.value = true
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'padron_licencias',
        Parametros: []
      }
    })

    // La API devuelve los datos en eResponse.data.result
    const apiResponse = response.data.eResponse || response.data
    const data = apiResponse.data?.result || apiResponse.data || []

    if (Array.isArray(data) && data.length > 0) {
      recaudadoras.value = data
    } else if (apiResponse.success === false) {
      toast.error(apiResponse.message || 'Error al cargar recaudadoras')
      recaudadoras.value = []
    } else {
      recaudadoras.value = []
      toast.warning('No se encontraron recaudadoras')
    }
  } catch (error) {
    console.error('Error fetchRecaudadoras:', error)
    toast.error('Error al cargar recaudadoras: ' + error.message)
  } finally {
    loading.value = false
  }
}

// Evento cuando cambia la recaudadora
const onRecaudadoraChange = async () => {
  form.value.mercado_id = ''
  mercados.value = []
  searchExecuted.value = false
  pagos.value = []

  if (!form.value.recaudadora_id) return

  loading.value = true
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_mercados_by_recaudadora',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_recaudadora_id', Valor: parseInt(form.value.recaudadora_id) }
        ]
      }
    })

    // La API devuelve los datos en eResponse.data.result
    const apiResponse = response.data.eResponse || response.data
    const data = apiResponse.data?.result || apiResponse.data || []

    if (Array.isArray(data) && data.length > 0) {
      mercados.value = data
    } else if (apiResponse.success === false) {
      toast.error(apiResponse.message || 'Error al cargar mercados')
      mercados.value = []
    } else {
      mercados.value = []
      toast.warning('No hay mercados para esta recaudadora')
    }
  } catch (error) {
    console.error('Error onRecaudadoraChange:', error)
    toast.error('Error al cargar mercados: ' + error.message)
  } finally {
    loading.value = false
  }
}

// Buscar pagos
const buscarPagos = async () => {
  if (!form.value.recaudadora_id || !form.value.mercado_id) {
    toast.warning('Debe seleccionar recaudadora y mercado')
    return
  }

  if (!form.value.fecha_desde || !form.value.fecha_hasta) {
    toast.warning('Debe especificar el rango de fechas')
    return
  }

  loading.value = true
  pagos.value = []
  searchExecuted.value = true

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_pagos_loc_grl',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_rec_id', Valor: parseInt(form.value.recaudadora_id) },
          { Nombre: 'p_mercado_id', Valor: parseInt(form.value.mercado_id) },
          { Nombre: 'p_fecha_desde', Valor: form.value.fecha_desde },
          { Nombre: 'p_fecha_hasta', Valor: form.value.fecha_hasta }
        ]
      }
    })

    // La API devuelve los datos en eResponse.data.result
    const apiResponse = response.data.eResponse || response.data
    const data = apiResponse.data?.result || apiResponse.data || []

    if (Array.isArray(data) && data.length > 0) {
      pagos.value = data
      toast.success(`Se encontraron ${pagos.value.length} pagos`)
    } else if (apiResponse.success === false) {
      toast.error(apiResponse.message || 'Error al buscar pagos')
      pagos.value = []
    } else {
      pagos.value = []
      toast.info('No se encontraron pagos en el periodo seleccionado')
    }
  } catch (error) {
    console.error('Error buscarPagos:', error)
    toast.error('Error al buscar pagos: ' + error.message)
  } finally {
    loading.value = false
  }
}

// Exportar a Excel
const exportarExcel = () => {
  if (pagos.value.length === 0) {
    toast.warning('No hay datos para exportar')
    return
  }

  try {
    // Crear CSV manualmente
    const headers = [
      'Mercado', 'Sección', 'Local', 'Letra', 'Bloque',
      'Año', 'Mes', 'Fecha Pago', 'Rec.', 'Caja', 'Operación',
      'Renta Pagada', 'Recibo', 'Fecha Mov.', 'Usuario',
      'Fecha Req.', 'Folio Req.', 'Periodos Req.'
    ]

    const rows = pagos.value.map(row => [
      row.num_mercado,
      row.seccion,
      row.local,
      row.letra_local || '',
      row.bloque || '',
      row.axo,
      row.periodo,
      row.fecha_pago,
      row.oficina_pago,
      row.caja_pago,
      row.operacion_pago,
      row.importe_pago,
      row.folio,
      row.fecha_modificacion,
      row.usuario,
      row.fecha_emision || '',
      row.folio_1 || '',
      row.requerimientos || ''
    ])

    const csv = [
      headers.join(','),
      ...rows.map(row => row.map(cell => `"${cell}"`).join(','))
    ].join('\n')

    // Crear blob y descargar
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
    const link = document.createElement('a')
    const url = URL.createObjectURL(blob)

    link.setAttribute('href', url)
    link.setAttribute('download', `pagos_mercado_${form.value.mercado_id}_${Date.now()}.csv`)
    link.style.visibility = 'hidden'

    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)

    toast.success('Archivo exportado correctamente')
  } catch (error) {
    console.error('Error exportarExcel:', error)
    toast.error('Error al exportar: ' + error.message)
  }
}

// Funciones de formateo
const formatDate = (date) => {
  if (!date) return '-'
  const d = new Date(date)
  return d.toLocaleDateString('es-MX')
}

const formatCurrency = (amount) => {
  if (!amount) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(amount)
}
</script>

<style src="@/styles/municipal-theme.css"></style>

<style scoped>
.mt-3 {
  margin-top: 1.5rem;
}

.text-right-municipal {
  text-align: right;
}
</style>
