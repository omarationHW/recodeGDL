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
                <select class="municipal-form-control" v-model="form.num_mercado" @change="onMercadoChange"
                  :disabled="loading || !form.oficina || localEncontrado" required>
                  <option value="">Seleccione...</option>
                  <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                    {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                  </option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Categoría <span class="required">*</span></label>
                <input type="text" class="municipal-form-control" v-model="form.categoria"
                  :disabled="true" readonly required
                  :style="{ backgroundColor: '#f5f5f5', cursor: 'not-allowed' }"
                  placeholder="Automático" />
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Sección</label>
                <select class="municipal-form-control" v-model="form.seccion" :disabled="loading || localEncontrado"
                  required>
                  <option value="">Seleccione...</option>
                  <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">
                    {{ sec.seccion }}
                  </option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Local</label>
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
                  <button v-if="form.oficina && form.num_mercado && !localEncontrado && !localSeleccionado" type="button"
                    class="btn-municipal-secondary me-2" @click="mostrarLocalesDisponibles" :disabled="loading">
                    <font-awesome-icon icon="list" />
                    Ver Locales Disponibles
                  </button>
                  <button v-if="localSeleccionado && !localEncontrado" type="submit" class="btn-municipal-primary" :disabled="loading">
                    <font-awesome-icon icon="search" />
                    Cargar datos del Local
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

      <!-- Listado de Locales Disponibles -->
      <div v-if="mostrarListaLocales && localesDisponibles.length > 0" class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Locales Disponibles en este Mercado
          </h5>
          <div class="header-right">
            <span class="badge-purple">{{ localesDisponibles.length }} locales</span>
            <button class="btn-sm btn-municipal-secondary ms-2" @click="mostrarListaLocales = false">
              <font-awesome-icon icon="times" />
            </button>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
            <table class="municipal-table table-sm">
              <thead class="municipal-table-header" style="position: sticky; top: 0; z-index: 10;">
                <tr>
                  <th>Cat.</th>
                  <th>Sec.</th>
                  <th>Local</th>
                  <th>Letra</th>
                  <th>Bloque</th>
                  <th>Nombre</th>
                  <th>Acción</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(local, index) in localesDisponibles" :key="index">
                  <td>{{ local.categoria }}</td>
                  <td>{{ local.seccion }}</td>
                  <td><strong>{{ local.local }}</strong></td>
                  <td>{{ local.letra_local || '-' }}</td>
                  <td>{{ local.bloque || '-' }}</td>
                  <td>{{ local.nombre }}</td>
                  <td>
                    <button class="btn-municipal-primary btn-sm" @click="seleccionarLocal(local)">
                      <font-awesome-icon icon="check" />
                      Usar
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
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

              <div class="form-group">
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
                <input type="number" class="municipal-form-control" v-model.number="energiaForm.numero"
                  :disabled="loading" min="1" required />
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
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'

const { showLoading, hideLoading } = useGlobalLoading()
const { showToast } = useToast()

// Estado
const loading = ref(false)
const recaudadoras = ref([])
const mercados = ref([])
const secciones = ref([])
const localEncontrado = ref(false)
const localInfo = ref(null)
const localesDisponibles = ref([])
const mostrarListaLocales = ref(false)
const localSeleccionado = ref(false)

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
  numero: null
})

// Computed
const currentYear = computed(() => new Date().getFullYear())
const maxDate = computed(() => new Date().toISOString().split('T')[0])

const mostrarAyuda = () => {
  showToast('Busque un local sin energía registrada para dar de alta el servicio de energía eléctrica. Los adeudos se generarán automáticamente desde la fecha de alta.', 'info')
}

// Cargar catálogos
const fetchRecaudadoras = async () => {
  try {
    showLoading('Cargando Alta de Energía', 'Preparando catálogos del sistema...')
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
        showToast(`Se cargaron ${recaudadoras.value.length} recaudadoras`, 'success')
      }
    } else {
      showToast(res.data.eResponse.message || 'Error al cargar recaudadoras', 'error')
    }
  } catch (err) {
    console.error('Error al cargar recaudadoras:', err)
    showToast('Error de conexión al cargar recaudadoras', 'error')
  } finally {
    loading.value = false
    hideLoading()
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
      showToast(res.data.eResponse.message || 'Error al cargar secciones', 'error')
    }
  } catch (err) {
    console.error('Error al cargar secciones:', err)
    showToast('Error de conexión al cargar secciones', 'error')
  }
}

const onRecaudadoraChange = async () => {
  if (!form.value.oficina) {
    mercados.value = []
    form.value.num_mercado = ''
    form.value.categoria = ''
    localSeleccionado.value = false
    return
  }

  try {
    loading.value = true
    const nivelUsuario = 1 // TODO: Obtener del store de usuario
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_catalogo_mercados',
        Base: 'padron_licencias',
        Parametros: [
          { nombre: 'p_oficina', tipo: 'integer', valor: parseInt(form.value.oficina) },
          { nombre: 'p_nivel_usuario', tipo: 'integer', valor: nivelUsuario }
        ]
      }
    })
    if (res.data.eResponse.success) {
      mercados.value = res.data.eResponse.data.result || []
      if (mercados.value.length > 0) {
        showToast(`Se cargaron ${mercados.value.length} mercados`, 'success')
      } else {
        showToast('No se encontraron mercados para esta recaudadora', 'warning')
      }
    } else {
      showToast(res.data.eResponse.message || 'Error al cargar mercados', 'error')
    }
  } catch (err) {
    console.error('Error al cargar mercados:', err)
    showToast('Error de conexión al cargar mercados', 'error')
  } finally {
    loading.value = false
  }
}

const onMercadoChange = () => {
  const mercadoSeleccionado = mercados.value.find(m => m.num_mercado_nvo == form.value.num_mercado)
  if (mercadoSeleccionado) {
    form.value.categoria = mercadoSeleccionado.categoria
  } else {
    form.value.categoria = ''
  }
  // Limpiar lista de locales disponibles al cambiar de mercado
  localesDisponibles.value = []
  mostrarListaLocales.value = false
  localSeleccionado.value = false
}

// Mostrar locales disponibles
const mostrarLocalesDisponibles = async () => {
  if (!form.value.oficina || !form.value.num_mercado) {
    showToast('Seleccione oficina y mercado primero', 'warning')
    return
  }

  loading.value = true
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_consulta_locales_buscar',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(form.value.oficina) },
          { Nombre: 'p_num_mercado', Valor: parseInt(form.value.num_mercado) },
          { Nombre: 'p_categoria', Valor: null },
          { Nombre: 'p_seccion', Valor: null },
          { Nombre: 'p_local', Valor: null },
          { Nombre: 'p_letra_local', Valor: null },
          { Nombre: 'p_bloque', Valor: null }
        ]
      }
    })

    if (res.data.eResponse.success) {
      localesDisponibles.value = res.data.eResponse.data.result || []
      if (localesDisponibles.value.length > 0) {
        mostrarListaLocales.value = true
        showToast(`Se encontraron ${localesDisponibles.value.length} locales`, 'success')
      } else {
        showToast('No se encontraron locales en este mercado', 'info')
      }
    } else {
      showToast(res.data.eResponse.message || 'Error al cargar locales', 'error')
    }
  } catch (err) {
    console.error('Error al cargar locales:', err)
    showToast('Error de conexión al cargar locales', 'error')
  } finally {
    loading.value = false
  }
}

// Seleccionar un local de la lista
const seleccionarLocal = (local) => {
  form.value.categoria = local.categoria
  form.value.seccion = local.seccion
  form.value.local = local.local
  form.value.letra_local = local.letra_local || ''
  form.value.bloque = local.bloque || ''
  mostrarListaLocales.value = false
  localSeleccionado.value = true
  showToast('Local seleccionado. Haga clic en "Cargar datos del Local" para continuar.', 'info')
}

// Buscar local
const buscarLocal = async () => {
  if (!form.value.oficina || !form.value.num_mercado || !form.value.categoria ||
    !form.value.seccion || !form.value.local) {
    showToast('Debe completar todos los campos requeridos', 'warning')
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
            showToast(resultEnergia[0].message || 'El local ya tiene energía registrada', 'warning')
          } else {
            // El local NO tiene energía, se puede continuar
            localInfo.value = local
            localEncontrado.value = true
            showToast('Local encontrado. Complete los datos de energía para continuar.', 'success')
          }
        } else {
          showToast(resEnergia.data.eResponse.message || 'Error al verificar energía', 'error')
        }
      } else {
        localInfo.value = null
        localEncontrado.value = false
        showToast('No se encontró el local', 'warning')
      }
    } else {
      showToast(resLocal.data.eResponse.message || 'Error al buscar local', 'error')
    }
  } catch (err) {
    console.error('Error al buscar local:', err)
    showToast('Error de conexión al buscar local', 'error')
  } finally {
    loading.value = false
  }
}

// Grabar energía
const grabarEnergia = async () => {
  if (!localInfo.value) {
    showToast('No hay un local seleccionado', 'error')
    return
  }

  // Validaciones
  if (!energiaForm.value.cve_consumo || !energiaForm.value.descripcion ||
    !energiaForm.value.cantidad || !energiaForm.value.vigencia ||
    !energiaForm.value.fecha_alta || !energiaForm.value.axo || !energiaForm.value.numero) {
    showToast('Debe completar todos los campos de energía', 'warning')
    return
  }

  if (energiaForm.value.cantidad <= 0) {
    showToast('La cantidad debe ser mayor a 0', 'warning')
    return
  }

  if (energiaForm.value.numero <= 0) {
    showToast('El número de oficio debe ser mayor a 0', 'warning')
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
          { Nombre: 'p_numero', Valor: String(energiaForm.value.numero) },
          { Nombre: 'p_user_id', Valor: 1 } // TODO: Obtener del contexto de usuario
        ],
        Esquema: 'publico'
      }
    })

    if (res.data.eResponse.success) {
      const result = res.data.eResponse.data.result || []
      if (result.length > 0 && result[0].success) {
        showToast(result[0].message || 'Energía eléctrica grabada correctamente', 'success')
        // Limpiar y resetear
        setTimeout(() => {
          limpiarBusqueda()
        }, 2000)
      } else {
        const errorMsg = result.length > 0 ? result[0].message : 'Error al grabar energía'
        showToast(errorMsg, 'error')
      }
    } else {
      showToast(res.data.eResponse.message || 'Error al grabar energía', 'error')
    }
  } catch (err) {
    console.error('Error al grabar energía:', err)
    showToast('Error de conexión al grabar energía', 'error')
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
    numero: null
  }
  localEncontrado.value = false
  localInfo.value = null
  mercados.value = []
  localesDisponibles.value = []
  mostrarListaLocales.value = false
  localSeleccionado.value = false
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

.badge-purple {
  background-color: #6f42c1;
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 0.25rem;
  font-size: 0.875rem;
  font-weight: 600;
}

.header-with-badge {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}
</style>
