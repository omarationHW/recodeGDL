<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="user-circle" />
      </div>
      <div class="module-view-info">
        <h1>Consulta Individual de Datos Generales</h1>
        <p>Inicio > Mercados > Datos Individuales</p>
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
        
        <button class="btn-municipal-secondary" @click="$router.back()">
          <font-awesome-icon icon="arrow-left" />
          Regresar
        </button>
        
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario de búsqueda -->
      <div class="municipal-card mb-4">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Buscar Local
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="buscarLocal" class="search-form">
            <div class="row align-items-end">
              <div class="col-md-8">
                <label class="municipal-form-label">ID del Local <span class="text-danger fw-bold">*</span></label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="searchIdLocal"
                  placeholder="Ingrese el ID del local (ej: 1)"
                  required
                  min="1"
                />
              </div>
              <div class="col-md-4">
                <button type="submit" class="btn-municipal-primary w-100" :disabled="!searchIdLocal">
                  <font-awesome-icon icon="search" />
                  Buscar
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Error -->
      <div v-if="error" class="municipal-card">
        <div class="municipal-card-body text-center py-5">
          <font-awesome-icon icon="exclamation-circle" size="3x" class="text-danger mb-3" />
          <p class="text-muted">{{ error }}</p>
          <button class="btn-municipal-primary mt-3" @click="limpiarError">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
        </div>
      </div>

      <!-- Contenido -->
      <template v-else-if="datosLoaded">
        <!-- Datos del Mercado -->
        <div class="row">
          <div class="col-md-6">
            <div class="municipal-card">
              <div class="municipal-card-header">
                <h5>
                  <font-awesome-icon icon="store" />
                  Datos del Local
                </h5>
              </div>
              <div class="municipal-card-body">
                <div class="info-grid">
                  <div class="info-item">
                    <span class="info-label">Control</span>
                    <span class="info-value text-primary fw-bold fs-5">{{ datos.id_local }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Mercado</span>
                    <span class="info-value">{{ mercado.descripcion }}</span>
                  </div>
                  <div class="info-item full-width">
                    <span class="info-label">Nombre</span>
                    <span class="info-value">{{ datos.nombre }}</span>
                  </div>
                  <div class="info-item full-width">
                    <span class="info-label">Arrendatario</span>
                    <span class="info-value">{{ datos.arrendatario || '-' }}</span>
                  </div>
                  <div class="info-item full-width">
                    <span class="info-label">Domicilio</span>
                    <span class="info-value">{{ datos.domicilio || '-' }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Sector</span>
                    <span class="info-value">{{ datos.sector }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Zona</span>
                    <span class="info-value">{{ datos.zona }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="col-md-6">
            <div class="municipal-card">
              <div class="municipal-card-header">
                <h5>
                  <font-awesome-icon icon="info-circle" />
                  Información Adicional
                </h5>
              </div>
              <div class="municipal-card-body">
                <div class="info-grid">
                  <div class="info-item full-width">
                    <span class="info-label">Descripción Local</span>
                    <span class="info-value">{{ datos.descripcion_local || '-' }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Superficie</span>
                    <span class="info-value">{{ datos.superficie }} m²</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Giro</span>
                    <span class="info-value">{{ datos.giro }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Fecha Alta</span>
                    <span class="info-value">{{ datos.fecha_alta }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Fecha Baja</span>
                    <span class="info-value">{{ datos.fecha_baja || '-' }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Actualización</span>
                    <span class="info-value">{{ datos.fecha_modificacion }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Vigencia</span>
                    <span class="info-value">{{ datos.vigencia }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Usuario</span>
                    <span class="info-value">{{ usuario.nombre }}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Renta</span>
                    <span class="info-value text-success fw-semibold">{{ formatCurrency(cuota.renta) }}</span>
                  </div>
                </div>
                <!-- Tianguis -->
                <template v-if="tianguis">
                  <hr />
                  <div class="info-grid">
                    <div class="info-item">
                      <span class="info-label">Descuento</span>
                      <span class="info-value">{{ tianguis.Descuento }}</span>
                    </div>
                    <div class="info-item">
                      <span class="info-label">Motivo Descuento</span>
                      <span class="info-value">{{ tianguis.MotivoDescuento }}</span>
                    </div>
                  </div>
                
  <DocumentationModal :show="showAyuda" :component-name="'DatosIndividuales'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - DatosIndividuales'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'DatosIndividuales'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - DatosIndividuales'" @close="showDocumentacion = false" />
</template>
              </div>
            </div>
          </div>
        </div>

        <!-- Adeudos -->
        <div class="municipal-card">
          <div class="municipal-card-header header-with-badge">
            <h5>
              <font-awesome-icon icon="file-invoice-dollar" />
              Adeudos
            </h5>
            <div class="header-right">
              <span class="badge-red" v-if="adeudos.length > 0">
                {{ adeudos.length }} pendientes
              </span>
              <span class="badge-green" v-else>
                Sin adeudos
              </span>
            </div>
          </div>
          <div class="municipal-card-body">
            <div v-if="adeudos.length > 0" class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Año</th>
                    <th>Mes</th>
                    <th class="text-end">Importe</th>
                    <th class="text-end">Recargos</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="a in adeudos" :key="a.axo + '-' + a.periodo" class="municipal-table-row">
                    <td>{{ a.axo }}</td>
                    <td>{{ a.periodo }}</td>
                    <td class="text-end">{{ formatCurrency(a.importe) }}</td>
                    <td class="text-end">{{ formatCurrency(a.recargos) }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div v-else class="text-center text-muted py-3">
              <font-awesome-icon icon="check-circle" size="2x" class="text-success mb-2 opacity-25" />
              <p>No hay adeudos pendientes</p>
            </div>
          </div>
        </div>

        <!-- Requerimientos -->
        <div class="municipal-card">
          <div class="municipal-card-header header-with-badge">
            <h5>
              <font-awesome-icon icon="clipboard-list" />
              Requerimientos
            </h5>
            <div class="header-right">
              <span class="badge-purple" v-if="requerimientos.length > 0">
                {{ requerimientos.length }}
              </span>
            </div>
          </div>
          <div class="municipal-card-body">
            <div v-if="requerimientos.length > 0" class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Folio</th>
                    <th>Fecha Emisión</th>
                    <th class="text-end">Importe Multa</th>
                    <th class="text-end">Importe Gastos</th>
                    <th>Vigencia</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="r in requerimientos" :key="r.folio" class="municipal-table-row">
                    <td>{{ r.folio }}</td>
                    <td>{{ r.fecha_emision }}</td>
                    <td class="text-end">{{ formatCurrency(r.importe_multa) }}</td>
                    <td class="text-end">{{ formatCurrency(r.importe_gastos) }}</td>
                    <td>{{ r.vigencia }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div v-else class="text-center text-muted py-3">
              <font-awesome-icon icon="inbox" size="2x" class="opacity-25 mb-2 text-secondary" />
              <p>No hay requerimientos</p>
            </div>
          </div>
        </div>

        <!-- Movimientos -->
        <div class="municipal-card">
          <div class="municipal-card-header header-with-badge">
            <h5>
              <font-awesome-icon icon="exchange-alt" />
              Movimientos
            </h5>
            <div class="header-right">
              <span class="badge-green" v-if="movimientos.length > 0">
                {{ movimientos.length }}
              </span>
            </div>
          </div>
          <div class="municipal-card-body">
            <div v-if="movimientos.length > 0" class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Año Memo</th>
                    <th>Número Memo</th>
                    <th>Nombre</th>
                    <th>Tipo Movimiento</th>
                    <th>Fecha</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="m in movimientos" :key="m.id_movimiento" class="municipal-table-row">
                    <td>{{ m.axo_memo }}</td>
                    <td>{{ m.numero_memo }}</td>
                    <td>{{ m.nombre }}</td>
                    <td>{{ m.tipo_movimiento }}</td>
                    <td>{{ m.fecha }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div v-else class="text-center text-muted py-3">
              <font-awesome-icon icon="inbox" size="2x" class="opacity-25 mb-2 text-secondary" />
              <p>No hay movimientos registrados</p>
            </div>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import axios from 'axios'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


const route = useRoute()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast } = useToast()

// Estado
const error = ref('')
const datosLoaded = ref(false)
const searchIdLocal = ref(null)
const datos = ref({})
const mercado = ref({})
const usuario = ref({})
const cuota = ref({})
const adeudos = ref([])
const requerimientos = ref([])
const movimientos = ref([])
const tianguis = ref(null)

const formatCurrency = (val) => {
  if (val == null) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN',
    minimumFractionDigits: 2
  }).format(parseFloat(val))
}

const mostrarAyuda = () => {
  showToast('Consulta completa de datos de un local de mercado', 'info')
}

const api = async (operacion, parametros, base = 'mercados') => {
  const resp = await apiService.execute(operacion, base, parametros, '', null, 'publico')
  if (!resp.success) {
    throw new Error(resp.message || 'Error API')
  }
  return resp.data.data.result || []
}

const limpiarError = () => {
  error.value = ''
}

const buscarLocal = () => {
  if (!searchIdLocal.value) {
    showToast('Por favor ingrese un ID de local', 'warning')
    return
  }
  cargarDatos(searchIdLocal.value)
}

const cargarDatos = async (id_local) => {
  showLoading('Cargando datos del local...')
  error.value = ''
  datosLoaded.value = false

  try {
    // 1. Datos principales
    let res = await api('sp_get_datos_individuales', [
      { nombre: 'p_id_local', valor: id_local }
    ], 'mercados')

    if (!res || res.length === 0) {
      throw new Error(`No se encontró el local con ID: ${id_local}`)
    }

    datos.value = res[0] || {}

    // 2. Mercado
    res = await api('sp_get_mercado', [
      { nombre: 'p_oficina', valor: datos.value.oficina },
      { nombre: 'p_num_mercado', valor: datos.value.num_mercado }
    ])
    mercado.value = res[0] || {}

    // 3. Usuario
    res = await api('sp_get_usuario', [
      { nombre: 'p_id_usuario', valor: datos.value.id_usuario }
    ])
    usuario.value = res[0] || {}

    // 4. Cuota
    res = await api('sp_get_cuota', [
      { nombre: 'p_axo', valor: new Date().getFullYear() },
      { nombre: 'p_categoria', valor: datos.value.categoria },
      { nombre: 'p_seccion', valor: datos.value.seccion },
      { nombre: 'p_clave_cuota', valor: datos.value.clave_cuota }
    ])
    cuota.value = res[0] || {}

    // 5. Adeudos
    adeudos.value = await api('sp_get_adeudos_local', [
      { nombre: 'p_id_local', valor: id_local }
    ])

    // 6. Requerimientos
    requerimientos.value = await api('sp_get_requerimientos_local', [
      { nombre: 'p_id_local', valor: id_local }
    ])

    // 7. Movimientos
    movimientos.value = await api('sp_get_movimientos_local', [
      { nombre: 'p_id_local', valor: id_local }
    ])

    // 8. Tianguis (si aplica)
    if (datos.value.num_mercado === 214) {
      res = await api('sp_get_tianguis', [
        { nombre: 'p_folio', valor: datos.value.local }
      ])
      tianguis.value = res[0] || null
    }

    datosLoaded.value = true
    showToast('Datos cargados correctamente', 'success')
  } catch (e) {
    error.value = e.message || 'Error al cargar datos'
    showToast(error.value, 'error')
    datosLoaded.value = false
  } finally {
    hideLoading()
  }
}

onMounted(() => {
  // Si viene un id_local por ruta, cargarlo automáticamente
  const id_local = route.params.id_local
  if (id_local) {
    searchIdLocal.value = parseInt(id_local)
    cargarDatos(id_local)
  }
})
</script>
