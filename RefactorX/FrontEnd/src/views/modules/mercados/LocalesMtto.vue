<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Mantenimiento de Locales</h1>
        <p>Inicio > Mercados > Locales Mtto</p>
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
        
        <button class="btn-municipal-primary" @click="abrirModalNuevo" :disabled="loading">
          <font-awesome-icon icon="plus" /> Nuevo Local
        </button>
        
      </div>
    </div>

    <div class="module-view-content">
      <!-- Tabla de locales -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Listado de Locales
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="locales.length > 0">
              {{ locales.length }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando locales...</p>
          </div>

          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th>Rec.</th>
                  <th>Mercado</th>
                  <th>Cat.</th>
                  <th>Secc.</th>
                  <th>Local</th>
                  <th>Let.</th>
                  <th>Blq.</th>
                  <th>Nombre</th>
                  <th>Giro</th>
                  <th>Sector</th>
                  <th>Superficie</th>
                  <th>Estado</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="locales.length === 0">
                  <td colspan="14" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No hay locales registrados</p>
                  </td>
                </tr>
                <tr v-else v-for="(local, idx) in paginatedLocales" :key="local.id_local" class="row-hover">
                  <td class="text-center">{{ (currentPage - 1) * itemsPerPage + idx + 1 }}</td>
                  <td>{{ local.oficina }}</td>
                  <td>{{ local.num_mercado }}</td>
                  <td>{{ local.categoria }}</td>
                  <td>{{ local.seccion }}</td>
                  <td><strong>{{ local.local }}</strong></td>
                  <td>{{ local.letra_local || '-' }}</td>
                  <td>{{ local.bloque || '-' }}</td>
                  <td>{{ local.nombre }}</td>
                  <td>{{ local.giro }}</td>
                  <td><span class="badge-info">{{ local.sector }}</span></td>
                  <td>{{ local.superficie }} m²</td>
                  <td>
                    <span :class="local.vigencia === 'A' ? 'badge-success' : 'badge-danger'">
                      {{ local.vigencia === 'A' ? 'VIGENTE' : 'BAJA' }}
                    </span>
                  </td>
                  <td class="text-center">
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-primary btn-sm" @click="editarLocal(local)" title="Editar">
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button class="btn-municipal-danger btn-sm" @click="confirmarEliminar(local)" title="Eliminar">
                        <font-awesome-icon icon="trash" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de paginación -->
          <div v-if="locales.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, locales.length) }}
                de {{ locales.length }} registros
              </span>
            </div>

            <div class="pagination-size">
              <label class="municipal-form-label me-2">Registros por página:</label>
              <select
                class="municipal-form-control form-control-sm"
                :value="itemsPerPage"
                @change="changeItemsPerPage($event.target.value)"
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
    </div>

    <!-- Modal para crear/editar local -->
    <div v-if="showModal" class="modal d-block">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <font-awesome-icon icon="store" />
              {{ isEdit ? 'Editar Local' : 'Nuevo Local' }}
            </h5>
            <button type="button" class="btn-close" @click="cerrarModal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="guardarLocal">
              <!-- Sección 1: Identificación del local -->
              <div class="form-section">
                <h6 class="form-section-title">Identificación del Local</h6>
                <div class="form-row">
                  <div class="form-group">
                    <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
                    <select v-model="form.oficina" class="municipal-form-control" required :disabled="isEdit || saving">
                      <option value="">Seleccione...</option>
                      <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                       {{ rec.id_rec }} - {{ rec.recaudadora }}
                      </option>
                    </select>
                  </div>
                  <div class="form-group" style="flex: 2;">
                    <label class="municipal-form-label">Mercado <span class="required">*</span></label>
                    <select v-model="form.num_mercado" class="municipal-form-control" required :disabled="isEdit || saving">
                      <option value="">Seleccione...</option>
                      <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                        {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                      </option>
                    </select>
                  </div>
                </div>

                <div class="form-row">
                  <div class="form-group">
                    <label class="municipal-form-label">Categoría <span class="required">*</span></label>
                    <select v-model="form.categoria" class="municipal-form-control" required :disabled="isEdit || saving">
                      <option value="">Seleccione...</option>
                      <option v-for="cat in categorias" :key="cat.categoria" :value="cat.categoria">
                        {{ cat.categoria }} - {{ cat.descripcion }}
                      </option>
                    </select>
                  </div>
                  <div class="form-group">
                    <label class="municipal-form-label">Sección <span class="required">*</span></label>
                    <select v-model="form.seccion" class="municipal-form-control" required :disabled="isEdit || saving">
                      <option value="">Seleccione...</option>
                      <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">
                        {{ sec.seccion }} - {{ sec.descripcion }}
                      </option>
                    </select>
                  </div>
                  <div class="form-group">
                    <label class="municipal-form-label">Local <span class="required">*</span></label>
                    <input type="number" v-model.number="form.local" class="municipal-form-control" required :disabled="isEdit || saving" />
                  </div>
                  <div class="form-group">
                    <label class="municipal-form-label">Letra</label>
                    <input type="text" v-model="form.letra_local" class="municipal-form-control" maxlength="1" :disabled="isEdit || saving" />
                  </div>
                  <div class="form-group">
                    <label class="municipal-form-label">Bloque</label>
                    <input type="text" v-model="form.bloque" class="municipal-form-control" maxlength="1" :disabled="isEdit || saving" />
                  </div>
                </div>
              </div>

              <!-- Sección 2: Datos del local -->
              <div class="form-section">
                <h6 class="form-section-title">Datos del Local</h6>
                <div class="form-row">
                  <div class="form-group" style="flex: 2;">
                    <label class="municipal-form-label">Nombre <span class="required">*</span></label>
                    <input type="text" v-model="form.nombre" class="municipal-form-control" required :disabled="saving" />
                  </div>
                  <div class="form-group" style="flex: 2;">
                    <label class="municipal-form-label">Giro <span class="required">*</span></label>
                    <select v-model.number="form.giro" class="municipal-form-control" required :disabled="saving">
                      <option value="">Seleccione...</option>
                      <option v-for="giro in giros" :key="giro.id_giro" :value="giro.id_giro">
                        {{ giro.id_giro }} - {{ giro.descripcion }}
                      </option>
                    </select>
                  </div>
                </div>

                <div class="form-row">
                  <div class="form-group">
                    <label class="municipal-form-label">Sector <span class="required">*</span></label>
                    <select v-model="form.sector" class="municipal-form-control" required :disabled="saving">
                      <option value="">Seleccione...</option>
                      <option value="J">J - Juridico</option>
                      <option value="R">R - Recaudación</option>
                      <option value="L">L - Legal</option>
                      <option value="H">H - Hacienda</option>
                    </select>
                  </div>
                  <div class="form-group" style="flex: 2;">
                    <label class="municipal-form-label">Domicilio</label>
                    <input type="text" v-model="form.domicilio" class="municipal-form-control" :disabled="saving" />
                  </div>
                </div>

                <div class="form-row">
                  <div class="form-group">
                    <label class="municipal-form-label">Superficie (m²) <span class="required">*</span></label>
                    <input type="number" v-model.number="form.superficie" class="municipal-form-control" step="0.01" min="0.01" required :disabled="saving" />
                  </div>
                  <div class="form-group" style="flex: 2;">
                    <label class="municipal-form-label">Descripción Local</label>
                    <input type="text" v-model="form.descripcion_local" class="municipal-form-control" :disabled="saving" />
                  </div>
                </div>

                <div class="form-row">
                  <div class="form-group">
                    <label class="municipal-form-label">Zona <span class="required">*</span></label>
                    <select v-model="form.zona" class="municipal-form-control" required :disabled="saving">
                      <option value="">Seleccione...</option>
                      <option v-for="zona in zonas" :key="zona.cvezona" :value="zona.cvezona">
                        {{ zona.cvezona }} - {{ zona.zona }}
                      </option>
                    </select>
                  </div>
                  <div class="form-group">
                    <label class="municipal-form-label">Clave Cuota <span class="required">*</span></label>
                    <select v-model="form.clave_cuota" class="municipal-form-control" required :disabled="saving">
                      <option value="">Seleccione...</option>
                      <option v-for="cuota in cuotas" :key="cuota.clave_cuota" :value="cuota.clave_cuota">
                        {{ cuota.clave_cuota }}
                      </option>
                    </select>
                  </div>
                  <div class="form-group">
                    <label class="municipal-form-label">Fecha Alta <span class="required">*</span></label>
                    <input type="date" v-model="form.fecha_alta" class="municipal-form-control" required :disabled="saving" />
                  </div>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="cerrarModal">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
            <button type="button" class="btn-municipal-primary" @click="guardarLocal" :disabled="saving">
              <font-awesome-icon :icon="saving ? 'spinner' : 'save'" :spin="saving" />
              {{ isEdit ? 'Actualizar' : 'Guardar' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de confirmación de eliminación -->
    <div v-if="showDeleteConfirm" class="modal-overlay">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header bg-danger text-white">
            <h5 class="modal-title">
              <font-awesome-icon icon="exclamation-triangle" /> Confirmar Eliminación
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="cancelarEliminar"></button>
          </div>
          <div class="modal-body">
            <p>¿Está seguro de eliminar este local?</p>
            <div class="alert alert-warning">
              <strong>Mercado:</strong> {{ localAEliminar?.num_mercado }}<br>
              <strong>Local:</strong> {{ localAEliminar?.local }}{{ localAEliminar?.letra_local || '' }}<br>
              <strong>Nombre:</strong> {{ localAEliminar?.nombre }}
            </div>
            <p class="text-danger"><strong>Esta acción no se puede deshacer.</strong></p>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="cancelarEliminar">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
            <button type="button" class="btn-municipal-danger" @click="eliminarLocal" :disabled="saving">
              <font-awesome-icon :icon="saving ? 'spinner' : 'trash'" :spin="saving" />
              Eliminar
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>

  <DocumentationModal :show="showAyuda" :component-name="'LocalesMtto'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - LocalesMtto'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'LocalesMtto'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - LocalesMtto'" @close="showDocumentacion = false" />
</template>

<script setup>
import apiService from '@/services/apiService';
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const confirmarAccion = async (titulo, texto, confirmarTexto = 'Sí, continuar') => {
  const result = await Swal.fire({
    title: titulo,
    text: texto,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#3085d6',
    cancelButtonColor: '#6c757d',
    confirmButtonText: confirmarTexto,
    cancelButtonText: 'Cancelar'
  })
  return result.isConfirmed
}

const mostrarConfirmacionEliminar = async (texto) => {
  const result = await Swal.fire({
    title: '¿Eliminar registro?',
    text: texto,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#d33',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })
  return result.isConfirmed
}

const showAyuda = ref(false)
const showDocumentacion = ref(false)


const { showLoading, hideLoading } = useGlobalLoading()
const { showToast } = useToast()

// Estado
const locales = ref([])
const recaudadoras = ref([])
const mercados = ref([])
const categorias = ref([])
const secciones = ref([])
const zonas = ref([])
const cuotas = ref([])
const giros = ref([])
const loading = ref(false)
const saving = ref(false)
const showModal = ref(false)
const showDeleteConfirm = ref(false)
const isEdit = ref(false)
const localAEliminar = ref(null)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)

// Formulario
const form = ref({
  id_local: null,
  oficina: '',
  num_mercado: '',
  categoria: '',
  seccion: '',
  local: '',
  letra_local: '',
  bloque: '',
  nombre: '',
  giro: '',
  sector: '',
  domicilio: '',
  zona: '',
  descripcion_local: '',
  superficie: '',
  fecha_alta: new Date().toISOString().split('T')[0],
  clave_cuota: ''
})

// Computed para paginación
const totalPages = computed(() => {
  return Math.ceil(locales.value.length / itemsPerPage.value)
})

const paginatedLocales = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return locales.value.slice(start, end)
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

const changeItemsPerPage = (newSize) => {
  itemsPerPage.value = parseInt(newSize)
  currentPage.value = 1
}

const resetPagination = () => {
  currentPage.value = 1
  itemsPerPage.value = 10
}

// Métodos de ayuda
const mostrarAyuda = () => {
  showToast('Administre los locales de mercados. Puede agregar, editar o eliminar locales.', 'info')
}

// Cargar datos iniciales
const cargarLocales = async () => {
  loading.value = true
  try {
    showLoading('Cargando locales', 'Obteniendo listado de locales...')
    const res = await apiService.execute(
          'sp_locales_list',
          'mercados',
          [],
          '',
          null,
          'publico'
        )

    if (res.success) {
      locales.value = res.data.result || []
      resetPagination()
      if (locales.value.length > 0) {
        showToast(`Se cargaron ${locales.value.length} locales`, 'success')
      }
    } else {
      showToast(res.message || 'Error al cargar locales', 'error')
    }
  } catch (err) {
    console.error('Error al cargar locales:', err)
    showToast('Error de conexión al cargar locales', 'error')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const cargarCatalogos = async () => {
  try {
    // Recaudadoras
    const recRes = await apiService.execute(
          'sp_get_recaudadoras',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    if (recRes.success) {
      recaudadoras.value = recRes.data.result || []
    }

    // Mercados (todos)
    const mercRes = await apiService.execute(
          'sp_get_catalogo_mercados',
          'mercados',
          [
          { nombre: 'p_oficina', tipo: 'integer', valor: null },
          { nombre: 'p_nivel_usuario', tipo: 'integer', valor: 1 }
        ],
          '',
          null,
          'publico'
        )
    if (mercRes.success) {
      mercados.value = mercRes.data.result || []
    }

    // Categorías
    const catRes = await apiService.execute(
          'sp_categoria_list',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    if (catRes.success) {
      categorias.value = catRes.data.result || []
    }

    // Secciones
    const secRes = await apiService.execute(
          'sp_get_secciones',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    if (secRes.success) {
      secciones.value = secRes.data.result || []
    }

    // Zonas
    const zonRes = await apiService.execute(
          'sp_zonas_list',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    if (zonRes.success) {
      zonas.value = zonRes.data.result || []
    }

    // Cuotas
    const cuoRes = await apiService.execute(
          'sp_cve_cuota_list',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    if (cuoRes.success) {
      cuotas.value = cuoRes.data.result || []
    }

    // Giros
    const girRes = await apiService.execute(
          'sp_get_giros_vigentes',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    if (girRes.success) {
      giros.value = girRes.data.result || []
    }
  } catch (err) {
    console.error('Error al cargar catálogos:', err)
    showToast('Error al cargar catálogos', 'error')
  }
}

// Modal
const abrirModalNuevo = () => {
  isEdit.value = false
  form.value = {
    id_local: null,
    oficina: '',
    num_mercado: '',
    categoria: '',
    seccion: '',
    local: '',
    letra_local: '',
    bloque: '',
    nombre: '',
    giro: '',
    sector: '',
    domicilio: '',
    zona: '',
    descripcion_local: '',
    superficie: '',
    fecha_alta: new Date().toISOString().split('T')[0],
    clave_cuota: ''
  }
  showModal.value = true
}

const editarLocal = (local) => {
  isEdit.value = true
  form.value = {
    id_local: local.id_local,
    oficina: local.oficina,
    num_mercado: local.num_mercado,
    categoria: local.categoria,
    seccion: local.seccion,
    local: local.local,
    letra_local: local.letra_local || '',
    bloque: local.bloque || '',
    nombre: local.nombre,
    giro: local.giro,
    sector: local.sector,
    domicilio: local.domicilio || '',
    zona: local.zona || '',
    descripcion_local: local.descripcion_local || '',
    superficie: local.superficie,
    fecha_alta: local.fecha_alta ? local.fecha_alta.split('T')[0] : new Date().toISOString().split('T')[0],
    clave_cuota: local.clave_cuota
  }
  showModal.value = true
}

const cerrarModal = () => {
  showModal.value = false
  isEdit.value = false
}

const guardarLocal = async () => {
  console.log('Guardando local:', JSON.stringify(form.value, null, 2))

  // Validar campos requeridos y construir lista de faltantes
  const camposFaltantes = []

  if (!form.value.oficina) camposFaltantes.push('Recaudadora')
  if (!form.value.num_mercado) camposFaltantes.push('Mercado')
  if (!form.value.categoria) camposFaltantes.push('Categoría')
  if (!form.value.seccion) camposFaltantes.push('Sección')
  if (!form.value.local) camposFaltantes.push('Local')
  if (!form.value.nombre || form.value.nombre.trim() === '') camposFaltantes.push('Nombre')
  if (!form.value.giro) camposFaltantes.push('Giro')
  if (!form.value.sector) camposFaltantes.push('Sector')
  if (!form.value.superficie) camposFaltantes.push('Superficie')
  if (!form.value.zona) camposFaltantes.push('Zona')
  if (!form.value.clave_cuota) camposFaltantes.push('Clave Cuota')

  if (camposFaltantes.length > 0) {
    const mensaje = `Faltan los siguientes campos: ${camposFaltantes.join(', ')}`
    showToast(mensaje, 'warning')
    return
  }

  saving.value = true
  try {
    showLoading(isEdit.value ? 'Actualizando local' : 'Guardando local', 'Por favor espere...')

    const operacion = isEdit.value ? 'sp_locales_update' : 'sp_locales_mtto_alta'

    // Construir parámetros según la operación
    let parametros = []

    if (isEdit.value) {
      // Parámetros para sp_locales_update (orden específico del SP)
      parametros = [
        { nombre: 'p_id_local', valor: form.value.id_local },
        { nombre: 'p_oficina', valor: form.value.oficina },
        { nombre: 'p_num_mercado', valor: form.value.num_mercado },
        { nombre: 'p_categoria', valor: form.value.categoria },
        { nombre: 'p_seccion', valor: form.value.seccion },
        { nombre: 'p_local', valor: form.value.local },
        { nombre: 'p_nombre', valor: form.value.nombre },
        { nombre: 'p_giro', valor: form.value.giro },
        { nombre: 'p_sector', valor: form.value.sector },
        { nombre: 'p_zona', valor: form.value.zona },
        { nombre: 'p_superficie', valor: form.value.superficie },
        { nombre: 'p_clave_cuota', valor: form.value.clave_cuota },
        { nombre: 'p_fecha_alta', valor: form.value.fecha_alta },
        { nombre: 'p_id_usuario', valor: 1 },
        { nombre: 'p_letra_local', valor: form.value.letra_local || null },
        { nombre: 'p_bloque', valor: form.value.bloque || null },
        { nombre: 'p_domicilio', valor: form.value.domicilio || null },
        { nombre: 'p_descripcion_local', valor: form.value.descripcion_local || null }
      ]
    } else {
      // Parámetros para sp_locales_mtto_alta (orden específico del nuevo SP)
      parametros = [
        { nombre: 'p_oficina', valor: form.value.oficina },
        { nombre: 'p_num_mercado', valor: form.value.num_mercado },
        { nombre: 'p_categoria', valor: form.value.categoria },
        { nombre: 'p_seccion', valor: form.value.seccion },
        { nombre: 'p_local', valor: form.value.local },
        { nombre: 'p_nombre', valor: form.value.nombre },
        { nombre: 'p_giro', valor: form.value.giro },
        { nombre: 'p_sector', valor: form.value.sector },
        { nombre: 'p_zona', valor: form.value.zona },
        { nombre: 'p_superficie', valor: form.value.superficie },
        { nombre: 'p_clave_cuota', valor: form.value.clave_cuota },
        { nombre: 'p_fecha_alta', valor: form.value.fecha_alta },
        { nombre: 'p_id_usuario', valor: 1 },
        { nombre: 'p_letra_local', valor: form.value.letra_local || null },
        { nombre: 'p_bloque', valor: form.value.bloque || null },
        { nombre: 'p_domicilio', valor: form.value.domicilio || null },
        { nombre: 'p_descripcion_local', valor: form.value.descripcion_local || null }
      ]
    }

    const res = await apiService.execute(operacion, 'mercados', parametros, '', null, 'publico')

    if (res?.success) {
      showToast(isEdit.value ? 'Local actualizado correctamente' : 'Local guardado correctamente', 'success')
      cerrarModal()
      await cargarLocales()
    } else {
      showToast(res.message || 'Error al guardar local', 'error')
    }
  } catch (err) {
    console.error('Error al guardar local:', err)
    showToast('Error de conexión al guardar local', 'error')
  } finally {
    saving.value = false
    hideLoading()
  }
}

// Eliminar
const confirmarEliminar = (local) => {
  localAEliminar.value = local
  showDeleteConfirm.value = true
}

const cancelarEliminar = () => {
  localAEliminar.value = null
  showDeleteConfirm.value = false
}

const eliminarLocal = async () => {
  if (!localAEliminar.value) return

  saving.value = true
  try {
    showLoading('Eliminando local', 'Por favor espere...')
    const res = await apiService.execute(
          'sp_locales_delete',
          'mercados',
          [
          { nombre: 'p_id_local', valor: localAEliminar.value.id_local }
        ],
          '',
          null,
          'publico'
        )

    if (res.success) {
      showToast('Local eliminado correctamente', 'success')
      cancelarEliminar()
      await cargarLocales()
    } else {
      showToast(res.message || 'Error al eliminar local', 'error')
    }
  } catch (err) {
    console.error('Error al eliminar local:', err)
    showToast('Error de conexión al eliminar local', 'error')
  } finally {
    saving.value = false
    hideLoading()
  }
}

onMounted(async () => {
  showLoading('Inicializando', 'Cargando datos...')
  try {
    await Promise.all([cargarCatalogos(), cargarLocales()])
  } finally {
    hideLoading()
  }
})
</script>
