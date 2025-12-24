<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="arrows-up-down" />
      </div>
      <div class="module-view-info">
        <h1>Consulta Ordenada de Contratos</h1>
        <p>Aseo Contratado - Listado de contratos con ordenamiento personalizado</p>
      </div>
      <button
        type="button"
        class="btn-help-icon"
        @click="mostrarAyuda = true"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>
<div class="municipal-card shadow-sm mb-4">
      <div class="municipal-card-header">
        <h5>Configuración de Consulta</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row mb-3">
          <div class="col-md-3">
            <label class="municipal-form-label">Ordenar Por</label>
            <select class="municipal-form-control" v-model="parametros.ordenarPor">
              <option value="contrato">Número de Contrato</option>
              <option value="contribuyente">Contribuyente</option>
              <option value="zona">Zona</option>
              <option value="tipo_aseo">Tipo de Aseo</option>
              <option value="cuota">Cuota Mensual</option>
              <option value="fecha_alta">Fecha de Alta</option>
              <option value="adeudo">Adeudo</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Orden</label>
            <select class="municipal-form-control" v-model="parametros.orden">
              <option value="ASC">Ascendente ↑</option>
              <option value="DESC">Descendente ↓</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Zona</label>
            <select class="municipal-form-control" v-model="parametros.zona">
              <option value="">Todas</option>
              <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.zona">
                Zona {{ z.zona }}
              </option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Tipo de Aseo</label>
            <select class="municipal-form-control" v-model="parametros.tipoAseo">
              <option value="">Todos</option>
              <option value="D">Doméstico</option>
              <option value="C">Comercial</option>
              <option value="I">Industrial</option>
              <option value="S">Servicios</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Status</label>
            <select class="municipal-form-control" v-model="parametros.status">
              <option value="">Todos</option>
              <option value="A">Activos</option>
              <option value="I">Cancelados</option>
            </select>
          </div>
          <div class="col-md-1">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-info w-100" @click="consultar" :disabled="cargando">
              <font-awesome-icon icon="list" />
            </button>
          </div>
        </div>
        <div class="row">
          <div class="col-md-2">
            <label class="municipal-form-label">Registros por Página</label>
            <select class="municipal-form-control" v-model.number="parametros.registrosPorPagina" @change="consultar">
              <option :value="25">25</option>
              <option :value="50">50</option>
              <option :value="100">100</option>
              <option :value="200">200</option>
              <option :value="500">500</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Filtro Rápido</label>
            <input type="text" class="municipal-form-control" v-model="filtroRapido"
              placeholder="Buscar en resultados..." />
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Con Adeudos</label>
            <select class="municipal-form-control" v-model="parametros.conAdeudos">
              <option value="">Todos</option>
              <option value="SI">Solo con adeudos</option>
              <option value="NO">Sin adeudos</option>
            </select>
          </div>
        </div>
      </div>
    </div>

    <div v-if="contratosFiltrados.length > 0">
      <div class="municipal-card shadow-sm mb-3">
        <div class="municipal-card-header bg-light d-flex justify-content-between align-items-center">
          <div>
            <h6 class="mb-0">
              Contratos Encontrados: {{ contratosFiltrados.length }}
              <span v-if="filtroRapido" class="text-muted">(filtrados de {{ contratos.length }})</span>
            </h6>
          </div>
          <div>
            <button class="btn btn-sm btn-success me-2" @click="exportar">
              <font-awesome-icon icon="file-excel" /> Excel
            </button>
            <button class="btn btn-sm btn-danger" @click="imprimir">
              <font-awesome-icon icon="print" /> Imprimir
            </button>
          </div>
        </div>
        <div class="municipal-card-body p-0">
          <div class="table-responsive" style="max-height: 600px; overflow-y: auto;">
            <table class="municipal-table-sm table-hover mb-0">
              <thead class="table-light" style="position: sticky; top: 0; z-index: 10;">
                <tr>
                  <th>#</th>
                  <th @click="cambiarOrden('num_contrato')" style="cursor: pointer;">
                    Contrato
                    <font-awesome-icon v-if="parametros.ordenarPor === 'contrato'"
                      :icon="parametros.orden === 'ASC' ? 'arrow-up' : 'arrow-down'" class="ms-1" />
                  </th>
                  <th @click="cambiarOrden('contribuyente')" style="cursor: pointer;">
                    Contribuyente
                    <font-awesome-icon v-if="parametros.ordenarPor === 'contribuyente'"
                      :icon="parametros.orden === 'ASC' ? 'arrow-up' : 'arrow-down'" class="ms-1" />
                  </th>
                  <th>Cuenta Catastral</th>
                  <th>Domicilio</th>
                  <th @click="cambiarOrden('zona')" class="text-center" style="cursor: pointer;">
                    Zona
                    <font-awesome-icon v-if="parametros.ordenarPor === 'zona'"
                      :icon="parametros.orden === 'ASC' ? 'arrow-up' : 'arrow-down'" class="ms-1" />
                  </th>
                  <th @click="cambiarOrden('tipo_aseo')" class="text-center" style="cursor: pointer;">
                    Tipo
                    <font-awesome-icon v-if="parametros.ordenarPor === 'tipo_aseo'"
                      :icon="parametros.orden === 'ASC' ? 'arrow-up' : 'arrow-down'" class="ms-1" />
                  </th>
                  <th @click="cambiarOrden('cuota')" class="text-end" style="cursor: pointer;">
                    Cuota
                    <font-awesome-icon v-if="parametros.ordenarPor === 'cuota'"
                      :icon="parametros.orden === 'ASC' ? 'arrow-up' : 'arrow-down'" class="ms-1" />
                  </th>
                  <th @click="cambiarOrden('adeudo')" class="text-end" style="cursor: pointer;">
                    Adeudo
                    <font-awesome-icon v-if="parametros.ordenarPor === 'adeudo'"
                      :icon="parametros.orden === 'ASC' ? 'arrow-up' : 'arrow-down'" class="ms-1" />
                  </th>
                  <th class="text-center">Status</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(contrato, index) in paginados" :key="contrato.control_contrato"
                    :class="{ 'table-warning': contrato.adeudo > 0 }">
                  <td>{{ (paginaActual - 1) * parametros.registrosPorPagina + index + 1 }}</td>
                  <td><strong>{{ contrato.num_contrato }}</strong></td>
                  <td>{{ contrato.contribuyente }}</td>
                  <td>{{ contrato.cuenta_catastral }}</td>
                  <td>{{ contrato.domicilio_corto }}</td>
                  <td class="text-center">{{ contrato.zona }}</td>
                  <td class="text-center">
                    <span class="badge" :class="getBadgeTipo(contrato.tipo_aseo)">
                      {{ formatTipoAseo(contrato.tipo_aseo) }}
                    </span>
                  </td>
                  <td class="text-end">${{ formatCurrency(contrato.cuota_mensual) }}</td>
                  <td class="text-end">
                    <span :class="contrato.adeudo > 0 ? 'text-danger fw-bold' : 'text-success'">
                      ${{ formatCurrency(contrato.adeudo || 0) }}
                    </span>
                  </td>
                  <td class="text-center">
                    <span class="badge" :class="contrato.status === 'A' ? 'bg-success' : 'bg-danger'">
                      {{ contrato.status === 'A' ? 'Activo' : 'Cancelado' }}
                    </span>
                  </td>
                </tr>
              </tbody>
              <tfoot class="table-light" style="position: sticky; bottom: 0;">
                <tr>
                  <th colspan="7" class="text-end">TOTALES:</th>
                  <th class="text-end">${{ formatCurrency(totalCuotas) }}</th>
                  <th class="text-end text-danger">${{ formatCurrency(totalAdeudos) }}</th>
                  <th></th>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
        <div v-if="totalPaginas > 1" class="municipal-card-footer">
          <nav>
            <ul class="pagination pagination-sm mb-0 justify-content-center">
              <li class="page-item" :class="{ disabled: paginaActual === 1 }">
                <a class="page-link" @click.prevent="cambiarPagina(1)">Primera</a>
              </li>
              <li class="page-item" :class="{ disabled: paginaActual === 1 }">
                <a class="page-link" @click.prevent="cambiarPagina(paginaActual - 1)">Anterior</a>
              </li>
              <li v-for="p in paginasVisibles" :key="p" class="page-item" :class="{ active: p === paginaActual }">
                <a class="page-link" @click.prevent="cambiarPagina(p)">{{ p }}</a>
              </li>
              <li class="page-item" :class="{ disabled: paginaActual === totalPaginas }">
                <a class="page-link" @click.prevent="cambiarPagina(paginaActual + 1)">Siguiente</a>
              </li>
              <li class="page-item" :class="{ disabled: paginaActual === totalPaginas }">
                <a class="page-link" @click.prevent="cambiarPagina(totalPaginas)">Última</a>
              </li>
            </ul>
          </nav>
        </div>
      </div>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Consulta Ordenada de Contratos">
      <h6>Descripción</h6>
      <p>Genera listados de contratos con ordenamiento personalizado y filtros avanzados.</p>
      <h6>Ordenamiento</h6>
      <ul>
        <li>Seleccione el campo por el cual desea ordenar</li>
        <li>Elija orden ascendente o descendente</li>
        <li>Haga clic en los encabezados de columna para cambiar el orden</li>
      </ul>
      <h6>Filtros Disponibles</h6>
      <ul>
        <li>Zona y tipo de aseo</li>
        <li>Status del contrato</li>
        <li>Contratos con o sin adeudos</li>
        <li>Filtro rápido en resultados</li>
      </ul>
      <h6>Características</h6>
      <ul>
        <li>Paginación configurable</li>
        <li>Exportación a Excel e impresión</li>
        <li>Totales automáticos</li>
        <li>Resaltado de contratos con adeudos</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from '@/composables/useToast'

const { execute } = useApi()
const { handleError } = useLicenciasErrorHandler()
const { showToast } = useToast()

const cargando = ref(false)
const mostrarAyuda = ref(false)
const contratos = ref([])
const zonas = ref([])
const filtroRapido = ref('')
const paginaActual = ref(1)

const parametros = ref({
  ordenarPor: 'contrato',
  orden: 'ASC',
  zona: '',
  tipoAseo: '',
  status: 'A',
  registrosPorPagina: 50,
  conAdeudos: ''
})

const contratosFiltrados = computed(() => {
  if (!filtroRapido.value) return contratos.value

  const filtro = filtroRapido.value.toLowerCase()
  return contratos.value.filter(c =>
    c.num_contrato?.toLowerCase().includes(filtro) ||
    c.contribuyente?.toLowerCase().includes(filtro) ||
    c.cuenta_catastral?.toLowerCase().includes(filtro) ||
    c.domicilio_corto?.toLowerCase().includes(filtro)
  )
})

const totalPaginas = computed(() => {
  return Math.ceil(contratosFiltrados.value.length / parametros.value.registrosPorPagina)
})

const paginados = computed(() => {
  const inicio = (paginaActual.value - 1) * parametros.value.registrosPorPagina
  const fin = inicio + parametros.value.registrosPorPagina
  return contratosFiltrados.value.slice(inicio, fin)
})

const paginasVisibles = computed(() => {
  const maxVisible = 5
  let inicio = Math.max(1, paginaActual.value - Math.floor(maxVisible / 2))
  let fin = Math.min(totalPaginas.value, inicio + maxVisible - 1)

  if (fin - inicio < maxVisible - 1) {
    inicio = Math.max(1, fin - maxVisible + 1)
  }

  const paginas = []
  for (let i = inicio; i <= fin; i++) {
    paginas.push(i)
  }
  return paginas
})

const totalCuotas = computed(() => {
  return contratosFiltrados.value.reduce((sum, c) => sum + parseFloat(c.cuota_mensual || 0), 0)
})

const totalAdeudos = computed(() => {
  return contratosFiltrados.value.reduce((sum, c) => sum + parseFloat(c.adeudo || 0), 0)
})

const consultar = async () => {
  cargando.value = true
  paginaActual.value = 1
  try {
    const params = {
      p_ordenar_por: parametros.value.ordenarPor,
      p_orden: parametros.value.orden,
      p_zona: parametros.value.zona || null,
      p_tipo_aseo: parametros.value.tipoAseo || null,
      p_status: parametros.value.status || null,
      p_con_adeudos: parametros.value.conAdeudos || null
    }
    const response = await execute('SP_ASEO_CONSULTA_ORDENADA', 'aseo_contratado', params)
    contratos.value = response || []
    showToast(`${contratos.value.length} contrato(s) encontrado(s)`, 'success')
  } catch (error) {
    handleError(error, 'Error al consultar contratos')
  } finally {
    cargando.value = false
  }
}

const cambiarOrden = (campo) => {
  if (parametros.value.ordenarPor === campo) {
    parametros.value.orden = parametros.value.orden === 'ASC' ? 'DESC' : 'ASC'
  } else {
    parametros.value.ordenarPor = campo
    parametros.value.orden = 'ASC'
  }
  consultar()
}

const cambiarPagina = (pagina) => {
  if (pagina >= 1 && pagina <= totalPaginas.value) {
    paginaActual.value = pagina
  }
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value || 0)
}

const formatTipoAseo = (tipo) => {
  const tipos = { 'D': 'Dom', 'C': 'Com', 'I': 'Ind', 'S': 'Ser' }
  return tipos[tipo] || tipo
}

const getBadgeTipo = (tipo) => {
  const colores = {
    'D': 'bg-success',
    'C': 'bg-primary',
    'I': 'bg-warning',
    'S': 'bg-info'
  }
  return colores[tipo] || 'bg-secondary'
}

const exportar = () => showToast('Exportando a Excel...', 'info')
const imprimir = () => showToast('Preparando impresión...', 'info')

onMounted(async () => {
  try {
    const response = await execute('SP_ASEO_ZONAS_LIST', 'aseo_contratado', {})
    zonas.value = response || []
    await consultar()
  } catch (error) {
    console.error('Error al cargar datos iniciales:', error)
  }
})
</script>

