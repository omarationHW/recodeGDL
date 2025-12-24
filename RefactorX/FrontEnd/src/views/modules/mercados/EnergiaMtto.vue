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
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book-open" />
          <span>Documentacion</span>
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          <span>Ayuda</span>
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
                <select class="municipal-form-control" v-model="form.categoria" :disabled="loading || localEncontrado" required>
                  <option value="">Seleccione...</option>
                  <option v-for="cat in categorias" :key="cat.categoria" :value="cat.categoria">
                    {{ cat.categoria }} - {{ cat.descripcion }}
                  </option>
                </select>
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
                <tr v-for="(local, index) in paginatedData" :key="index">
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

          <!-- Controles de paginación -->
          <div v-if="localesDisponibles.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, localesDisponibles.length) }}
                de {{ localesDisponibles.length }} registros
              </span>
            </div>

            <div class="pagination-size">
              <label class="municipal-form-label me-2">Registros por página:</label>
              <select
                class="municipal-form-control form-control-sm"
                :value="itemsPerPage"
                @change="changePageSize($event.target.value)"
                style="width: auto; display: inline-block;"
              >
                <option value="10">10</option>
                <option value="25">25</option>
                <option value="50">50</option>
                <option value="100">100</option>
              </select>
            </div>

            <div class="pagination-buttons">
              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(1)"
                :disabled="currentPage === 1"
                title="Primera página"
              >
                <font-awesome-icon icon="angle-double-left" />
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(currentPage - 1)"
                :disabled="currentPage === 1"
                title="Página anterior"
              >
                <font-awesome-icon icon="angle-left" />
              </button>

              <button
                v-for="page in visiblePages"
                :key="page"
                class="btn-sm"
                :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
                @click="goToPage(page)"
              >
                {{ page }}
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(currentPage + 1)"
                :disabled="currentPage === totalPages"
                title="Página siguiente"
              >
                <font-awesome-icon icon="angle-right" />
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(totalPages)"
                :disabled="currentPage === totalPages"
                title="Última página"
              >
                <font-awesome-icon icon="angle-double-right" />
              </button>
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

  <DocumentationModal :show="showAyuda" :component-name="'EnergiaMtto'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - EnergiaMtto'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'EnergiaMtto'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - EnergiaMtto'" @close="showDocumentacion = false" />
</template>

<script setup>
import apiService from '@/services/apiService';
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


const { showLoading, hideLoading } = useGlobalLoading()
const { showToast } = useToast()

// Estado
const loading = ref(false)
const recaudadoras = ref([])
const mercados = ref([])
const categorias = ref([])
const secciones = ref([])
const localEncontrado = ref(false)
const localInfo = ref(null)
const localesDisponibles = ref([])
const mostrarListaLocales = ref(false)
const localSeleccionado = ref(false)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)

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

// Computed para paginación
const totalPages = computed(() => {
  return Math.ceil(localesDisponibles.value.length / itemsPerPage.value)
})

const paginatedData = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return localesDisponibles.value.slice(start, end)
})

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPages.value, startPage + maxVisible - 1)

  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }

  return pages
})

// Métodos de paginación
const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

const changePageSize = (newSize) => {
  itemsPerPage.value = parseInt(newSize)
  currentPage.value = 1
}

const mostrarAyuda = () => {
  showToast('Busque un local sin energía registrada para dar de alta el servicio de energía eléctrica. Los adeudos se generarán automáticamente desde la fecha de alta.', 'info')
}

// Cargar catálogos
const fetchRecaudadoras = async () => {
  try {
    showLoading('Cargando Alta de Energía', 'Preparando catálogos del sistema...')
    loading.value = true
    const res = await apiService.execute(
          'sp_get_recaudadoras',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    if (res.success) {
      recaudadoras.value = res.data.result || []
      if (recaudadoras.value.length > 0) {
        showToast(`Se cargaron ${recaudadoras.value.length} recaudadoras`, 'success')
      }
    } else {
      showToast(res.message || 'Error al cargar recaudadoras', 'error')
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
    const res = await apiService.execute(
          'sp_get_secciones',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    if (res.success) {
      secciones.value = res.data.result || []
    } else {
      showToast(res.message || 'Error al cargar secciones', 'error')
    }
  } catch (err) {
    console.error('Error al cargar secciones:', err)
    showToast('Error de conexión al cargar secciones', 'error')
  }
}

const fetchCategorias = async () => {
  try {
    const res = await apiService.execute(
          'sp_categoria_list',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    if (res.success) {
      categorias.value = res.data.result || []
    } else {
      showToast(res.message || 'Error al cargar categorías', 'error')
    }
  } catch (err) {
    console.error('Error al cargar categorías:', err)
    showToast('Error de conexión al cargar categorías', 'error')
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
    const res = await apiService.execute(
          'sp_get_catalogo_mercados',
          'mercados',
          [
          { nombre: 'p_oficina', tipo: 'integer', valor: parseInt(form.value.oficina) },
          { nombre: 'p_nivel_usuario', tipo: 'integer', valor: nivelUsuario }
        ],
          '',
          null,
          'publico'
        )
    if (res.success) {
      mercados.value = res.data.result || []
      if (mercados.value.length > 0) {
        showToast(`Se cargaron ${mercados.value.length} mercados`, 'success')
      } else {
        showToast('No se encontraron mercados para esta recaudadora', 'warning')
      }
    } else {
      showToast(res.message || 'Error al cargar mercados', 'error')
    }
  } catch (err) {
    console.error('Error al cargar mercados:', err)
    showToast('Error de conexión al cargar mercados', 'error')
  } finally {
    loading.value = false
  }
}

const onMercadoChange = () => {
  // No auto-llenar categoría - dejar que el usuario seleccione
  form.value.categoria = ''
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
    const res = await apiService.execute(
          'sp_consulta_locales_buscar',
          'mercados',
          [
          { nombre: 'p_oficina', valor: parseInt(form.value.oficina) },
          { nombre: 'p_num_mercado', valor: parseInt(form.value.num_mercado) },
          { nombre: 'p_categoria', valor: null },
          { nombre: 'p_seccion', valor: null },
          { nombre: 'p_local', valor: null },
          { nombre: 'p_letra_local', valor: null },
          { nombre: 'p_bloque', valor: null }
        ],
          '',
          null,
          'publico'
        )

    if (res.success) {
      localesDisponibles.value = res.data.result || []
      currentPage.value = 1 // Resetear a la primera página
      if (localesDisponibles.value.length > 0) {
        mostrarListaLocales.value = true
        showToast(`Se encontraron ${localesDisponibles.value.length} locales`, 'success')
      } else {
        showToast('No se encontraron locales en este mercado', 'info')
      }
    } else {
      showToast(res.message || 'Error al cargar locales', 'error')
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
    const resLocal = await apiService.execute(
          'sp_buscar_local',
          'mercados',
          [
          { nombre: 'p_oficina', valor: parseInt(form.value.oficina) },
          { nombre: 'p_num_mercado', valor: parseInt(form.value.num_mercado) },
          { nombre: 'p_categoria', valor: parseInt(form.value.categoria) },
          { nombre: 'p_seccion', valor: form.value.seccion },
          { nombre: 'p_local', valor: parseInt(form.value.local) },
          { nombre: 'p_letra_local', valor: form.value.letra_local || '' },
          { nombre: 'p_bloque', valor: form.value.bloque || '' }
        ],
          '',
          null,
          'publico'
        )

    if (resLocal.success) {
      const resultLocal = resLocal.data.result || []
      if (resultLocal.length > 0) {
        const local = resultLocal[0]

        // 2. Verificar si el local tiene energía en mercados
        const resEnergia = await apiService.execute(
          'sp_verificar_local_sin_energia',
          'mercados',
          [
              { nombre: 'p_id_local', valor: local.id_local }
            ],
          '',
          null,
          'publico'
        )

        if (resEnergia.success) {
          const resultEnergia = resEnergia.data.result || []
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
          showToast(resEnergia.message || 'Error al verificar energía', 'error')
        }
      } else {
        localInfo.value = null
        localEncontrado.value = false
        showToast('No se encontró el local', 'warning')
      }
    } else {
      showToast(resLocal.message || 'Error al buscar local', 'error')
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
    const res = await apiService.execute(
          'sp_alta_energia_mtto',
          'mercados',
          [
          { nombre: 'p_id_local', valor: localInfo.value.id_local },
          { nombre: 'p_cve_consumo', valor: energiaForm.value.cve_consumo },
          { nombre: 'p_descripcion', valor: energiaForm.value.descripcion },
          { nombre: 'p_cantidad', valor: parseFloat(energiaForm.value.cantidad) },
          { nombre: 'p_vigencia', valor: energiaForm.value.vigencia },
          { nombre: 'p_fecha_alta', valor: energiaForm.value.fecha_alta },
          { nombre: 'p_axo', valor: parseInt(energiaForm.value.axo) },
          { nombre: 'p_numero', valor: String(energiaForm.value.numero) },
          { nombre: 'p_user_id', valor: 1 } // TODO: Obtener del contexto de usuario
        ],
          '',
          null,
          'publico'
        )

    if (res.success) {
      const result = res.data.result || []
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
      showToast(res.message || 'Error al grabar energía', 'error')
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
  fetchCategorias()
})
</script>
