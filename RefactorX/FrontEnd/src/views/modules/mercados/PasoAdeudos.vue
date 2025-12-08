<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calculator" />
      </div>
      <div class="module-view-info">
        <h1>Generación de Adeudos Tianguis</h1>
        <p>Inicio > Operaciones > Paso de Adeudos (Mercado 214)</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="calendar" /> Parámetros de Generación</h5>
        </div>
        <div class="municipal-card-body">
          <div class="row g-3">
            <div class="col-md-6">
              <label class="municipal-form-label">Año</label>
              <input type="number" v-model.number="form.ano" class="municipal-form-control" min="2009"
                :max="new Date().getFullYear() + 1" placeholder="Ingrese el año" />
            </div>
            <div class="col-md-6">
              <label class="municipal-form-label">Trimestre</label>
              <select v-model.number="form.trimestre" class="municipal-form-control">
                <option :value="1">1er Trimestre (Enero-Marzo)</option>
                <option :value="2">2do Trimestre (Abril-Junio)</option>
                <option :value="3">3er Trimestre (Julio-Septiembre)</option>
                <option :value="4">4to Trimestre (Octubre-Diciembre)</option>
              </select>
            </div>
          </div>
          <div class="button-row mt-3">
            <button class="btn-municipal-primary" @click="generarAdeudos" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'calculator'" :spin="loading" />
              {{ loading ? 'Generando...' : 'Generar Adeudos' }}
            </button>
          </div>
        </div>
      </div>

      <div v-if="adeudos.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list" /> Previsualización de Adeudos</h5>
          <div class="header-right">
            <span class="badge-purple">{{ adeudos.length }} registros</span>
            <span class="badge-success ms-2">Total: {{ formatCurrency(totalImporte) }}</span>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th>ID Local</th>
                  <th>Nombre</th>
                  <th>Domicilio</th>
                  <th class="text-end">Superficie (m²)</th>
                  <th class="text-end">Importe Cuota</th>
                  <th class="text-center">Periodo</th>
                  <th class="text-end">Importe Adeudo</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in adeudos" :key="idx" class="row-hover">
                  <td class="text-center">{{ idx + 1 }}</td>
                  <td><strong class="text-primary">{{ row.id_local }}</strong></td>
                  <td>{{ row.nombre }}</td>
                  <td>{{ row.domicilio }}</td>
                  <td class="text-end">{{ formatNumber(row.superficie) }}</td>
                  <td class="text-end">{{ formatCurrency(row.importe_cuota) }}</td>
                  <td class="text-center">
                    <span class="badge-info">T{{ row.periodo }}</span>
                  </td>
                  <td class="text-end"><strong>{{ formatCurrency(row.importe_adeudo) }}</strong></td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="table-footer">
                  <td colspan="7" class="text-end"><strong>TOTAL:</strong></td>
                  <td class="text-end"><strong>{{ formatCurrency(totalImporte) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>
          <div class="button-row mt-3">
            <button class="btn-municipal-success" @click="insertarAdeudos" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'save'" :spin="loading" />
              {{ loading ? 'Insertando...' : 'Insertar Adeudos en BD' }}
            </button>
            <button class="btn-municipal-secondary" @click="limpiarAdeudos">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
          </div>
        </div>
      </div>

      <div v-if="resultado.show" class="municipal-card mt-3">
        <div class="municipal-card-header" :class="resultado.type === 'success' ? 'bg-success' : 'bg-warning'">
          <h5 class="text-white">
            <font-awesome-icon :icon="resultado.type === 'success' ? 'check-circle' : 'exclamation-triangle'" />
            Resultado de la Inserción
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="alert" :class="resultado.type === 'success' ? 'alert-success' : 'alert-warning'">
            <strong>{{ resultado.insertados }} de {{ resultado.total }} adeudos insertados correctamente</strong>
          </div>
          <div v-if="resultado.errores.length > 0" class="alert alert-danger">
            <strong><font-awesome-icon icon="times-circle" /> Errores encontrados ({{ resultado.errores.length
              }}):</strong>
            <ul class="mb-0 mt-2" style="max-height: 200px; overflow-y: auto;">
              <li v-for="(err, idx) in resultado.errores" :key="idx">{{ err }}</li>
            </ul>
          </div>
        </div>
      </div>
    </div>

    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import axios from 'axios'

const form = ref({
  ano: new Date().getFullYear(),
  trimestre: 1
})

const adeudos = ref([])
const loading = ref(false)
const toast = ref({ show: false, type: 'info', message: '' })
const resultado = ref({ show: false, type: 'success', insertados: 0, total: 0, errores: [] })

const totalImporte = computed(() => {
  return adeudos.value.reduce((sum, row) => sum + parseFloat(row.importe_adeudo || 0), 0)
})

const showToast = (type, message) => {
  toast.value = { show: true, type, message }
  setTimeout(() => hideToast(), 5000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = { success: 'check-circle', error: 'times-circle', warning: 'exclamation-triangle', info: 'info-circle' }
  return icons[type] || 'info-circle'
}

const mostrarAyuda = () => {
  showToast('info', 'Genere adeudos para el Tianguis (Mercado 214) seleccionando el año y trimestre. El importe se calcula como: (Superficie * Importe Cuota) * 13')
}

const generarAdeudos = async () => {
  if (!form.value.ano || form.value.ano < 2009) {
    showToast('warning', 'Ingrese un año válido (mayor o igual a 2009)')
    return
  }

  loading.value = true
  adeudos.value = []
  resultado.value.show = false

  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_tianguis_locales',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_ano', Valor: parseInt(form.value.ano) }
        ]
      }
    })
    console.log(res.data)

    if (res.data.eResponse.success) {
      console.log(res.data.eResponse.data)
      const locales = res.data.eResponse.data.result

      if (locales.length === 0) {
        showToast('warning', 'No se encontraron locales activos para el año seleccionado')
        return
      }

      // Generar adeudos para cada local
      const adeudosGenerados = []
      locales.forEach(local => {
        if (local.superficie && local.importe_cuota) {
          const importeAdeudo = (parseFloat(local.superficie) * parseFloat(local.importe_cuota)) * 13
          adeudosGenerados.push({
            id_local: local.id_local,
            nombre: local.nombre,
            domicilio: local.domicilio,
            superficie: local.superficie,
            importe_cuota: local.importe_cuota,
            periodo: form.value.trimestre,
            importe_adeudo: importeAdeudo
          })
        }
      })

      adeudos.value = adeudosGenerados
      showToast('success', `${adeudosGenerados.length} adeudos generados correctamente`)
    } else {
      showToast('error', res.data.eResponse.message || 'Error al obtener locales')
    }
  } catch (err) {
    showToast('error', 'Error de conexión: ' + err.message)
  } finally {
    loading.value = false
  }
}

const insertarAdeudos = async () => {
  if (adeudos.value.length === 0) {
    showToast('warning', 'No hay adeudos para insertar')
    return
  }

  if (!confirm(`¿Está seguro de insertar ${adeudos.value.length} adeudos? Esta acción no se puede deshacer.`)) {
    return
  }

  loading.value = true
  const insertados = []
  const errores = []

  for (let i = 0; i < adeudos.value.length; i++) {
    const adeudo = adeudos.value[i]
    try {
      const res = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_insertar_adeudo_local',
          Base: 'mercados',
          Parametros: [
            { Nombre: 'p_id_local', Valor: parseInt(adeudo.id_local) },
            { Nombre: 'p_ano', Valor: parseInt(form.value.ano) },
            { Nombre: 'p_periodo', Valor: parseInt(adeudo.periodo) },
            { Nombre: 'p_importe', Valor: parseFloat(adeudo.importe_adeudo) },
            { Nombre: 'p_id_usuario', Valor: 1 }
          ]
        }
      })

      if (res.data.eResponse.success) {
        const result = res.data.eResponse.data.result[0]
        if (result.success) {
          insertados.push(adeudo.id_local)
        } else {
          errores.push(`Local ${adeudo.id_local}: ${result.message}`)
        }
      } else {
        errores.push(`Local ${adeudo.id_local}: ${res.data.eResponse.message}`)
      }
    } catch (err) {
      errores.push(`Local ${adeudo.id_local}: Error de conexión`)
    }
  }

  loading.value = false
  resultado.value = {
    show: true,
    type: insertados.length === adeudos.value.length ? 'success' : 'warning',
    insertados: insertados.length,
    total: adeudos.value.length,
    errores: errores
  }

  if (insertados.length === adeudos.value.length) {
    showToast('success', `¡Proceso completado! ${insertados.length} adeudos insertados`)
    setTimeout(() => {
      adeudos.value = []
    }, 3000)
  } else if (insertados.length > 0) {
    showToast('warning', `Proceso completado con errores: ${insertados.length} insertados, ${errores.length} fallidos`)
  } else {
    showToast('error', 'No se pudieron insertar adeudos')
  }
}

const limpiarAdeudos = () => {
  adeudos.value = []
  resultado.value.show = false
}

const formatCurrency = (val) => {
  if (val === null || val === undefined) return '$0.00'
  const num = typeof val === 'number' ? val : parseFloat(val)
  return '$' + num.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const formatNumber = (val) => {
  if (val === null || val === undefined) return '0'
  const num = typeof val === 'number' ? val : parseFloat(val)
  return num.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}
</script>

<style scoped>
.bg-success {
  background: linear-gradient(135deg, #28a745 0%, #218838 100%) !important;
}

.bg-warning {
  background: linear-gradient(135deg, #ffc107 0%, #e0a800 100%) !important;
}

.table-footer {
  background: #f8f9fa;
  font-weight: 600;
}
</style>
