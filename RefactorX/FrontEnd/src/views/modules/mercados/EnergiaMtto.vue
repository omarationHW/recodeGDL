<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="bolt" />
      </div>
      <div class="module-view-info">
        <h1>Alta de Locales para Energía Eléctrica</h1>
        <p>Inicio > Mercados > Mantenimiento > Alta de Energía</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Búsqueda de Local -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Búsqueda de Local
          </h5>
        </div>

        <div class="municipal-card-body">
          <form @submit.prevent="buscarLocal">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
                <select class="municipal-form-control" v-model="form.oficina" :disabled="loading || localEncontrado"
                  @change="onRecaudadoraChange" required>
                  <option value="">Seleccione...</option>
                  <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                    {{ rec.id_rec }} - {{ rec.recaudadora }}
                  </option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Mercado <span class="required">*</span></label>
                <select class="municipal-form-control" v-model="form.num_mercado" :disabled="loading || !form.oficina || localEncontrado"
                  required>
                  <option value="">Seleccione...</option>
                  <option v-for="merc in mercados" :key="merc.num_mercado" :value="merc.num_mercado">
                    {{ merc.num_mercado }} - {{ merc.descripcion }}
                  </option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Categoría <span class="required">*</span></label>
                <input type="number" class="municipal-form-control" v-model.number="form.categoria"
                  :disabled="loading || localEncontrado" min="1" max="9" required />
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Sección <span class="required">*</span></label>
                <select class="municipal-form-control" v-model="form.seccion" :disabled="loading || localEncontrado"
                  required>
                  <option value="">Seleccione...</option>
                  <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">
                    {{ sec.seccion }}
                  </option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Local <span class="required">*</span></label>
                <input type="number" class="municipal-form-control" v-model.number="form.local"
                  :disabled="loading || localEncontrado" min="1" required />
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Letra</label>
                <input type="text" class="municipal-form-control" v-model="form.letra_local"
                  :disabled="loading || localEncontrado" maxlength="1" />
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Bloque</label>
                <input type="text" class="municipal-form-control" v-model="form.bloque"
                  :disabled="loading || localEncontrado" maxlength="1" />
              </div>
            </div>

            <div class="row mt-3">
              <div class="col-12">
                <div class="text-end">
                  <button v-if="!localEncontrado" type="submit" class="btn-municipal-primary" :disabled="loading">
                    <font-awesome-icon icon="search" />
                    Buscar Local
                  </button>
                  <button v-if="localEncontrado" type="button" class="btn-municipal-secondary" @click="limpiarBusqueda"
                    :disabled="loading">
                    <font-awesome-icon icon="times" />
                    Nueva Búsqueda
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Información del Local Encontrado -->
      <div v-if="localInfo" class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="info-circle" />
            Información del Local
          </h5>
          <div class="header-right">
            <span class="badge-green">Local encontrado</span>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="row">
            <div class="col-md-3">
              <p><strong>Mercado:</strong> {{ localInfo.descripcion_mercado }}</p>
            </div>
            <div class="col-md-3">
              <p><strong>Nombre:</strong> {{ localInfo.nombre || 'N/A' }}</p>
            </div>
            <div class="col-md-3">
              <p><strong>Ubicación:</strong> Cat. {{ localInfo.categoria }}, Sec. {{ localInfo.seccion }}, Local {{ localInfo.local }}</p>
            </div>
            <div class="col-md-3">
              <p><strong>ID Local:</strong> {{ localInfo.id_local }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Formulario de Alta de Energía -->
      <div v-if="localEncontrado" class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="bolt" />
            Datos de Energía Eléctrica
          </h5>
        </div>

        <div class="municipal-card-body">
          <form @submit.prevent="grabarEnergia">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Clave de Consumo <span class="required">*</span></label>
                <select class="municipal-form-control" v-model="energiaForm.cve_consumo" :disabled="loading" required>
                  <option value="F">F - Fijo</option>
                  <option value="V">V - Variable</option>
                  <option value="E">E - Especial</option>
                </select>
              </div>

              <div class="form-group col-md-3">
                <label class="municipal-form-label">Descripción Local <span class="required">*</span></label>
                <input type="text" class="municipal-form-control" v-model="energiaForm.descripcion"
                  :disabled="loading" maxlength="50" required />
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Cantidad/Mes <span class="required">*</span></label>
                <input type="number" class="municipal-form-control" v-model.number="energiaForm.cantidad"
                  :disabled="loading" min="0" step="0.01" required />
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Vigencia <span class="required">*</span></label>
                <select class="municipal-form-control" v-model="energiaForm.vigencia" :disabled="loading" required>
                  <option value="A">A - Vigente</option>
                  <option value="E">E - Vigente para Emisión</option>
                  <option value="B">B - Baja</option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Fecha de Alta <span class="required">*</span></label>
                <input type="date" class="municipal-form-control" v-model="energiaForm.fecha_alta"
                  :disabled="loading" :max="maxDate" required />
              </div>
            </div>

            <div class="form-row mt-3">
              <div class="form-group">
                <label class="municipal-form-label">Año <span class="required">*</span></label>
                <input type="number" class="municipal-form-control" v-model.number="energiaForm.axo"
                  :disabled="loading" min="1995" :max="currentYear" required />
              </div>

              <div class="form-group col-md-3">
                <label class="municipal-form-label">Número de Oficio <span class="required">*</span></label>
                <input type="text" class="municipal-form-control" v-model="energiaForm.numero"
                  :disabled="loading" maxlength="20" required />
              </div>
            </div>

            <div class="row mt-4">
              <div class="col-12">
                <div class="text-end">
                  <button type="button" class="btn-municipal-secondary me-2" @click="limpiarBusqueda"
                    :disabled="loading">
                    <font-awesome-icon icon="times" />
                    Cancelar
                  </button>
                  <button type="submit" class="btn-municipal-primary" :disabled="loading">
                    <font-awesome-icon :icon="loading ? 'spinner' : 'save'" :spin="loading" />
                    {{ loading ? 'Grabando...' : 'Grabar Energía' }}
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Loading Spinner -->
      <div v-if="loading && !localEncontrado" class="text-center py-5">
        <div class="spinner-border text-primary" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
        <p class="mt-3 text-muted">Procesando, por favor espere...</p>
      </div>
    </div>

    <!-- Toast Notifications -->
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
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'

// Estado
const loading = ref(false)
const recaudadoras = ref([])
const mercados = ref([])
const secciones = ref([])
const localEncontrado = ref(false)
const localInfo = ref(null)

// Formulario de búsqueda
const form = ref({
  oficina: '',
  num_mercado: '',
  categoria: '',
  seccion: '',
  local: '',
  letra_local: '',
  bloque: ''
})

// Formulario de energía
const energiaForm = ref({
  cve_consumo: 'F',
  descripcion: '',
  cantidad: '',
  vigencia: 'A',
  fecha_alta: '',
  axo: new Date().getFullYear(),
  numero: ''
})

// Toast
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

// Computed
const currentYear = computed(() => new Date().getFullYear())
const maxDate = computed(() => new Date().toISOString().split('T')[0])

// Métodos de Toast
const showToast = (type, message) => {
  toast.value = {
    show: true,
    type,
    message
  }
  setTimeout(() => {
    hideToast()
  }, 5000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'times-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

const mostrarAyuda = () => {
  showToast('info', 'Busque un local sin energía registrada para dar de alta el servicio de energía eléctrica. Los adeudos se generarán automáticamente desde la fecha de alta.')
}

// Cargar catálogos
const fetchRecaudadoras = async () => {
  try {
    loading.value = true
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'padron_licencias',
        Parametros: []
      }
    })
    if (res.data.eResponse.success) {
      recaudadoras.value = res.data.eResponse.data.result || []
      if (recaudadoras.value.length > 0) {
        showToast('success', `Se cargaron ${recaudadoras.value.length} recaudadoras`)
      }
    } else {
      showToast('error', res.data.eResponse.message || 'Error al cargar recaudadoras')
    }
  } catch (err) {
    console.error('Error al cargar recaudadoras:', err)
    showToast('error', 'Error de conexión al cargar recaudadoras')
  } finally {
    loading.value = false
  }
}

const fetchSecciones = async () => {
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_secciones',
        Base: 'padron_licencias',
        Parametros: []
      }
    })
    if (res.data.eResponse.success) {
      secciones.value = res.data.eResponse.data.result || []
    } else {
      showToast('error', res.data.eResponse.message || 'Error al cargar secciones')
    }
  } catch (err) {
    console.error('Error al cargar secciones:', err)
    showToast('error', 'Error de conexión al cargar secciones')
  }
}

const onRecaudadoraChange = async () => {
  if (!form.value.oficina) {
    mercados.value = []
    return
  }

  try {
    loading.value = true
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_mercados_by_recaudadora',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_id_rec', Valor: parseInt(form.value.oficina) }
        ]
      }
    })
    if (res.data.eResponse.success) {
      mercados.value = res.data.eResponse.data.result || []
      if (mercados.value.length > 0) {
        showToast('success', `Se cargaron ${mercados.value.length} mercados`)
      } else {
        showToast('warning', 'No se encontraron mercados para esta recaudadora')
      }
    } else {
      showToast('error', res.data.eResponse.message || 'Error al cargar mercados')
    }
  } catch (err) {
    console.error('Error al cargar mercados:', err)
    showToast('error', 'Error de conexión al cargar mercados')
  } finally {
    loading.value = false
  }
}

// Buscar local
const buscarLocal = async () => {
  if (!form.value.oficina || !form.value.num_mercado || !form.value.categoria ||
    !form.value.seccion || !form.value.local) {
    showToast('warning', 'Debe completar todos los campos requeridos')
    return
  }

  loading.value = true

  try {
    // 1. Buscar el local en padron_licencias
    const resLocal = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_buscar_local',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(form.value.oficina) },
          { Nombre: 'p_num_mercado', Valor: parseInt(form.value.num_mercado) },
          { Nombre: 'p_categoria', Valor: parseInt(form.value.categoria) },
          { Nombre: 'p_seccion', Valor: form.value.seccion },
          { Nombre: 'p_local', Valor: parseInt(form.value.local) },
          { Nombre: 'p_letra_local', Valor: form.value.letra_local || '' },
          { Nombre: 'p_bloque', Valor: form.value.bloque || '' }
        ]
      }
    })

    if (resLocal.data.eResponse.success) {
      const resultLocal = resLocal.data.eResponse.data.result || []
      if (resultLocal.length > 0) {
        const local = resultLocal[0]

        // 2. Verificar si el local tiene energía en mercados
        const resEnergia = await axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_verificar_local_sin_energia',
            Base: 'mercados',
            Parametros: [
              { Nombre: 'p_id_local', Valor: local.id_local }
            ]
          }
        })

        if (resEnergia.data.eResponse.success) {
          const resultEnergia = resEnergia.data.eResponse.data.result || []
          if (resultEnergia.length > 0 && resultEnergia[0].tiene_energia) {
            // El local YA tiene energía
            localInfo.value = null
            localEncontrado.value = false
            showToast('warning', resultEnergia[0].message || 'El local ya tiene energía registrada')
          } else {
            // El local NO tiene energía, se puede continuar
            localInfo.value = local
            localEncontrado.value = true
            showToast('success', 'Local encontrado. Complete los datos de energía para continuar.')
          }
        } else {
          showToast('error', resEnergia.data.eResponse.message || 'Error al verificar energía')
        }
      } else {
        localInfo.value = null
        localEncontrado.value = false
        showToast('warning', 'No se encontró el local')
      }
    } else {
      showToast('error', resLocal.data.eResponse.message || 'Error al buscar local')
    }
  } catch (err) {
    console.error('Error al buscar local:', err)
    showToast('error', 'Error de conexión al buscar local')
  } finally {
    loading.value = false
  }
}

// Grabar energía
const grabarEnergia = async () => {
  if (!localInfo.value) {
    showToast('error', 'No hay un local seleccionado')
    return
  }

  // Validaciones
  if (!energiaForm.value.cve_consumo || !energiaForm.value.descripcion ||
    !energiaForm.value.cantidad || !energiaForm.value.vigencia ||
    !energiaForm.value.fecha_alta || !energiaForm.value.axo || !energiaForm.value.numero) {
    showToast('warning', 'Debe completar todos los campos de energía')
    return
  }

  if (energiaForm.value.cantidad <= 0) {
    showToast('warning', 'La cantidad debe ser mayor a 0')
    return
  }

  loading.value = true

  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_alta_energia_mtto',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_id_local', Valor: localInfo.value.id_local },
          { Nombre: 'p_cve_consumo', Valor: energiaForm.value.cve_consumo },
          { Nombre: 'p_descripcion', Valor: energiaForm.value.descripcion },
          { Nombre: 'p_cantidad', Valor: parseFloat(energiaForm.value.cantidad) },
          { Nombre: 'p_vigencia', Valor: energiaForm.value.vigencia },
          { Nombre: 'p_fecha_alta', Valor: energiaForm.value.fecha_alta },
          { Nombre: 'p_axo', Valor: parseInt(energiaForm.value.axo) },
          { Nombre: 'p_numero', Valor: energiaForm.value.numero },
          { Nombre: 'p_user_id', Valor: 1 } // TODO: Obtener del contexto de usuario
        ]
      }
    })

    if (res.data.eResponse.success) {
      const result = res.data.eResponse.data.result || []
      if (result.length > 0 && result[0].success) {
        showToast('success', result[0].message || 'Energía eléctrica grabada correctamente')
        // Limpiar y resetear
        setTimeout(() => {
          limpiarBusqueda()
        }, 2000)
      } else {
        const errorMsg = result.length > 0 ? result[0].message : 'Error al grabar energía'
        showToast('error', errorMsg)
      }
    } else {
      showToast('error', res.data.eResponse.message || 'Error al grabar energía')
    }
  } catch (err) {
    console.error('Error al grabar energía:', err)
    showToast('error', 'Error de conexión al grabar energía')
  } finally {
    loading.value = false
  }
}

// Limpiar búsqueda
const limpiarBusqueda = () => {
  form.value = {
    oficina: '',
    num_mercado: '',
    categoria: '',
    seccion: '',
    local: '',
    letra_local: '',
    bloque: ''
  }
  energiaForm.value = {
    cve_consumo: 'F',
    descripcion: '',
    cantidad: '',
    vigencia: 'A',
    fecha_alta: '',
    axo: new Date().getFullYear(),
    numero: ''
  }
  localEncontrado.value = false
  localInfo.value = null
  mercados.value = []
}

// Lifecycle
onMounted(() => {
  fetchRecaudadoras()
  fetchSecciones()
})
</script>

<style scoped>
/* Los estilos están definidos en municipal-theme.css */

.required {
  color: #dc3545;
}

.spinner-border {
  width: 3rem;
  height: 3rem;
}

.badge-green {
  background-color: #28a745;
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 0.25rem;
  font-size: 0.875rem;
  font-weight: 600;
}
</style>
