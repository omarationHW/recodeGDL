<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="plus-circle" />
      </div>
      <div class="module-view-info">
        <h1>Alta de Locales de Mercados</h1>
        <p>Inicio > Mercados > Alta de Locales</p>
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
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="selectedRec" @change="onRecChange" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="form-group" style="flex: 2;">
              <label class="municipal-form-label">Mercado <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="form.num_mercado" @change="onMercadoChange"
                :disabled="!selectedRec || loading">
                <option value="">Seleccione...</option>
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                  {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Cat. <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="form.categoria" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="cat in categorias" :key="cat.categoria" :value="cat.categoria">
                  {{ cat.categoria }} - {{ cat.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Sección <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="form.seccion" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">
                  {{ sec.seccion }} - {{ sec.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Local <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="form.local" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Letra</label>
              <input type="text" class="municipal-form-control" v-model="form.letra_local" maxlength="1"
                :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Bloque</label>
              <input type="text" class="municipal-form-control" v-model="form.bloque" maxlength="1"
                :disabled="loading" />
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-12">
              <div class="text-end">
                <button class="btn-municipal-primary" @click="buscarLocal" :disabled="loading">
                  <font-awesome-icon icon="search" />
                  Buscar
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Formulario de Alta -->
      <div v-if="mostrarFormulario" class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="edit" />
            Datos del Nuevo Local
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group" style="flex: 2;">
              <label class="municipal-form-label">Nombre <span class="required">*</span></label>
              <input type="text" class="municipal-form-control" v-model="form.nombre" :disabled="saving" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Giro <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="form.giro" min="1"
                :disabled="saving" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Sector <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="form.sector" :disabled="saving">
                <option value="">Seleccione...</option>
                <option value="J">J</option>
                <option value="R">R</option>
                <option value="L">L</option>
                <option value="H">H</option>
              </select>
            </div>
            <div class="form-group" style="flex: 2;">
              <label class="municipal-form-label">Domicilio</label>
              <input type="text" class="municipal-form-control" v-model="form.domicilio" :disabled="saving" />
            </div>
          </div>

          <div class="form-row mt-3">
            <div class="form-group">
              <label class="municipal-form-label">Superficie <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="form.superficie" step="0.01"
                min="0.01" :disabled="saving" />
            </div>
            <div class="form-group" style="flex: 2;">
              <label class="municipal-form-label">Descripción Local</label>
              <input type="text" class="municipal-form-control" v-model="form.descripcion_local" :disabled="saving" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Zona <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="form.zona" :disabled="saving">
                <option value="">Seleccione...</option>
                <option v-for="zona in zonas" :key="zona.id_zona" :value="zona.id_zona">
                  {{ zona.id_zona }} - {{ zona.zona }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Clave Cuota <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="form.clave_cuota" :disabled="saving">
                <option value="">Seleccione...</option>
                <option v-for="cuota in cuotas" :key="cuota.clave_cuota" :value="cuota.clave_cuota">
                  {{ cuota.clave_cuota }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Alta <span class="required">*</span></label>
              <input type="date" class="municipal-form-control" v-model="form.fecha_alta" :disabled="saving" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Memo <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="form.numero_memo" min="1"
                :disabled="saving" />
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-12">
              <div class="text-end">
                <button class="btn-municipal-primary me-2" @click="altaLocal" :disabled="saving">
                  <font-awesome-icon icon="save" />
                  Guardar Local
                </button>
                <button class="btn-municipal-secondary" @click="cancelar" :disabled="saving">
                  <font-awesome-icon icon="times" />
                  Cancelar
                </button>
              </div>
            </div>
          </div>
        </div>
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
import { ref, onMounted } from 'vue'
import axios from 'axios'

// Estado
const recaudadoras = ref([])
const mercados = ref([])
const categorias = ref([])
const secciones = ref([])
const zonas = ref([])
const cuotas = ref([])
const selectedRec = ref('')
const mostrarFormulario = ref(false)
const loading = ref(false)
const saving = ref(false)

const form = ref({
  num_mercado: '', categoria: '', seccion: '', local: '', letra_local: '', bloque: '',
  nombre: '', giro: '', sector: '', domicilio: '', zona: '', descripcion_local: '',
  superficie: '', fecha_alta: new Date().toISOString().split('T')[0], clave_cuota: '', numero_memo: ''
})

// Toast
const toast = ref({ show: false, type: 'info', message: '' })

const mostrarAyuda = () => {
  showToast('info', 'Ayuda: Busque si existe el local y si no existe podrá darlo de alta')
}

const showToast = (type, message) => {
  toast.value = { show: true, type, message }
  setTimeout(() => hideToast(), 5000)
}

const hideToast = () => { toast.value.show = false }

const getToastIcon = (type) => {
  const icons = { success: 'check-circle', error: 'times-circle', warning: 'exclamation-triangle', info: 'info-circle' }
  return icons[type] || 'info-circle'
}

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

    if (res.data.eResponse.success === true) {
      recaudadoras.value = res.data.eResponse.data.result || []
    } else {
      showToast('error', res.data.eResponse?.message || 'Error al cargar recaudadoras')
    }
  } catch (err) {
    console.error('Error al cargar recaudadoras:', err)
    showToast('error', 'Error de conexión al cargar recaudadoras')
  } finally {
    loading.value = false
  }
}

const onRecChange = async () => {
  // Limpiar mercado y categoría al cambiar recaudadora
  form.value.num_mercado = ''
  form.value.categoria = ''
  mercados.value = []

  if (!selectedRec.value) return

  // Cargar mercados
  loading.value = true
  try {
    const nivelUsuario = 1 // TODO: Obtener del store de usuario
    const oficinaParam = selectedRec.value || null

    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_catalogo_mercados',
        Base: 'padron_licencias',
        Parametros: [
          { nombre: 'p_oficina', tipo: 'integer', valor: oficinaParam },
          { nombre: 'p_nivel_usuario', tipo: 'integer', valor: nivelUsuario }
        ]
      }
    })

    if (res.data.eResponse && res.data.eResponse.success === true) {
      mercados.value = res.data.eResponse.data.result || []
      if (mercados.value.length > 0) {
        showToast('success', `Se cargaron ${mercados.value.length} mercados`)
      } else {
        showToast('info', 'No se encontraron mercados para esta oficina')
      }
    } else {
      showToast('error', res.data.eResponse?.message || 'Error al cargar mercados')
      mercados.value = []
    }
  } catch (err) {
    console.error('Error al cargar mercados:', err)
    showToast('error', 'Error de conexión al cargar mercados')
    mercados.value = []
  } finally {
    loading.value = false
  }
}

const cargarMercados = async () => {
  // Esta función ya no es necesaria, se movió la lógica a onRecChange
  // Se mantiene para evitar errores si se llama desde otro lugar
  return
}

const onMercadoChange = () => {
  const selected = mercados.value.find(m => m.num_mercado_nvo == form.value.num_mercado)
  if (selected) {
    form.value.categoria = selected.categoria
  }
}

const fetchSecciones = async () => {
  try {
    loading.value = true
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_secciones',
        Base: 'padron_licencias',
        Parametros: []
      }
    })

    if (response.data?.eResponse?.success) {
      secciones.value = response.data.eResponse.data.result || []
    }
  } catch (err) {
    console.error('Error al cargar secciones:', err)
    showToast('error', 'Error al cargar secciones')
  } finally {
    loading.value = false
  }
}

const cargarCatalogos = async () => {
  console.log('Cargando catálogos...')
  try {
    loading.value = true
    // Categorías - Base: mercados
    const catRes = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_categoria_list',
        Base: 'mercados',
        Parametros: []
      }
    })
    if (catRes.data.eResponse?.success) {
      categorias.value = catRes.data.eResponse.data.result || []
    }

    // Cuotas - Base: padron_licencias
    const cuoRes = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cve_cuota_list',
        Base: 'padron_licencias',
        Parametros: []
      }
    })
    if (cuoRes.data.eResponse?.success) {
      cuotas.value = cuoRes.data.eResponse.data.result || []
    }

    // Zonas - Base: padron_licencias
    const zonRes = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_zonas',
        Base: 'padron_licencias',
        Parametros: []
      }
    })
    if (zonRes.data.eResponse?.success) {
      zonas.value = zonRes.data.eResponse.data.result || []
    }
  } catch (err) {
    console.error('Error al cargar catálogos:', err)
    showToast('error', 'Error de conexión al cargar catálogos')
  } finally {
    loading.value = false
  }
}

const buscarLocal = async () => {
  if (!selectedRec.value || !form.value.num_mercado || !form.value.categoria || !form.value.seccion || !form.value.local) {
    showToast('warning', 'Complete los campos de búsqueda requeridos')
    return
  }

  loading.value = true
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_locales_mtto_buscar',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_oficina', Valor: selectedRec.value },
          { Nombre: 'p_num_mercado', Valor: form.value.num_mercado },
          { Nombre: 'p_categoria', Valor: form.value.categoria },
          { Nombre: 'p_seccion', Valor: form.value.seccion },
          { Nombre: 'p_local', Valor: form.value.local },
          { Nombre: 'p_letra_local', Valor: form.value.letra_local || null },
          { Nombre: 'p_bloque', Valor: form.value.bloque || null }
        ]
      }
    })

    if (res.data.eResponse?.success) {
      const result = res.data.eResponse.data.result?.[0]
      if (result?.existe) {
        showToast('error', 'El local ya existe. Verifique los datos.')
        mostrarFormulario.value = false
      } else {
        mostrarFormulario.value = true
        showToast('info', 'Local no encontrado. Puede proceder con el alta.')
      }
    }
  } catch (err) {
    showToast('error', 'Error al buscar local')
  } finally {
    loading.value = false
  }
}

const altaLocal = async () => {
  if (!form.value.nombre || !form.value.giro || !form.value.sector || !form.value.superficie || !form.value.clave_cuota || !form.value.numero_memo) {
    showToast('warning', 'Complete todos los campos requeridos')
    return
  }

  saving.value = true
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_locales_mtto_alta',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_oficina', Valor: selectedRec.value },
          { Nombre: 'p_num_mercado', Valor: form.value.num_mercado },
          { Nombre: 'p_categoria', Valor: form.value.categoria },
          { Nombre: 'p_seccion', Valor: form.value.seccion },
          { Nombre: 'p_local', Valor: form.value.local },
          { Nombre: 'p_letra_local', Valor: form.value.letra_local || null },
          { Nombre: 'p_bloque', Valor: form.value.bloque || null },
          { Nombre: 'p_nombre', Valor: form.value.nombre },
          { Nombre: 'p_giro', Valor: form.value.giro },
          { Nombre: 'p_sector', Valor: form.value.sector },
          { Nombre: 'p_domicilio', Valor: form.value.domicilio || '' },
          { Nombre: 'p_zona', Valor: form.value.zona || 1 },
          { Nombre: 'p_descripcion_local', Valor: form.value.descripcion_local || '' },
          { Nombre: 'p_superficie', Valor: form.value.superficie },
          { Nombre: 'p_clave_cuota', Valor: form.value.clave_cuota },
          { Nombre: 'p_fecha_alta', Valor: form.value.fecha_alta },
          { Nombre: 'p_numero_memo', Valor: form.value.numero_memo },
          { Nombre: 'p_id_usuario', Valor: 1 }
        ]
      }
    })

    if (res.data.eResponse?.success) {
      const result = res.data.eResponse.data.result?.[0]
      if (result?.success) {
        showToast('success', 'Local dado de alta correctamente')
        limpiarFormulario()
        mostrarFormulario.value = false
      } else {
        showToast('error', result?.message || 'Error al dar de alta')
      }
    }
  } catch (err) {
    showToast('error', 'Error al dar de alta el local')
  } finally {
    saving.value = false
  }
}

const cancelar = () => {
  mostrarFormulario.value = false
}

const limpiarFormulario = () => {
  form.value.nombre = ''
  form.value.giro = ''
  form.value.sector = ''
  form.value.domicilio = ''
  form.value.zona = ''
  form.value.descripcion_local = ''
  form.value.superficie = ''
  form.value.clave_cuota = ''
  form.value.numero_memo = ''
}

onMounted(async () => {
  try {
    await Promise.all([
      fetchRecaudadoras(),
      fetchSecciones(),
      cargarCatalogos()
    ])
    showToast('success', 'Catálogos cargados correctamente')
  } catch (err) {
    console.error('Error al inicializar:', err)
  }
})
</script>

<style scoped>
.required {
  color: #dc3545;
}
</style>
