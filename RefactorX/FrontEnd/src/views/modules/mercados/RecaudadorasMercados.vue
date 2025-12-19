<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Recaudadoras y Mercados</h1>
        <p>Inicio > Catálogos > Recaudadoras y Mercados</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="abrirModalNuevo" :disabled="loading">
          <font-awesome-icon icon="plus" />
          Agregar
        </button>
        <button class="btn-municipal-primary" @click="imprimirReporte" :disabled="loading || mercados.length === 0">
          <font-awesome-icon icon="print" />
          Imprimir
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header" @click="toggleFilters" style="cursor: pointer;">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Consulta
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Oficina (Recaudadora)</label>
              <select class="municipal-form-control" v-model="selectedRec" @change="onRecChange" :disabled="loading">
                <option value="">Todas las recaudadoras</option>
                <option v-for="rec in recaudadoras" :key="rec.id_recaudadora" :value="rec.id_recaudadora">
                  {{ rec.id_recaudadora }} - {{ rec.descripcion }}
                </option>
              </select>
            </div>
          </div>

          <!-- Botones de acción -->
          <div class="row mt-3">
            <div class="col-12">
              <div class="text-end">
                <button class="btn-municipal-primary me-2" @click="cargarCatalogo" :disabled="loading">
                  <font-awesome-icon icon="sync-alt" />
                  Actualizar
                </button>
                <button class="btn-municipal-secondary" @click="limpiarFiltros" :disabled="loading">
                  <font-awesome-icon icon="eraser" />
                  Limpiar
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Catálogo de Mercados
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="mercados.length > 0">
              {{ formatNumber(mercados.length) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de loading -->
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando catálogo de mercados, por favor espere...</p>
          </div>

          <!-- Mensaje de error -->
          <div v-else-if="error" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ error }}
          </div>

          <!-- Tabla -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Oficina</th>
                  <th>Mercado Nvo</th>
                  <th>Categoría</th>
                  <th>Descripción</th>
                  <th>Cta. Ingreso</th>
                  <th>Cta. Energía</th>
                  <th>ID Zona</th>
                  <th>Tipo Emisión</th>
                  <th>Mercado</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="mercados.length === 0">
                  <td colspan="10" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No hay mercados registrados en el sistema</p>
                  </td>
                </tr>
                <tr v-else v-for="(row, index) in paginatedMercados" :key="index" class="row-hover">
                  <td><strong class="text-primary">{{ row.oficina }}</strong></td>
                  <td>{{ row.num_mercado_nvo }}</td>
                  <td>{{ row.categoria }}</td>
                  <td>{{ row.descripcion }}</td>
                  <td class="text-end">{{ formatNumber(row.cuenta_ingreso) }}</td>
                  <td class="text-end">{{ formatNumber(row.cuenta_energia) }}</td>
                  <td>{{ row.id_zona }}</td>
                  <td class="text-center">
                    <span class="badge" :class="getTipoEmisionClass(row.tipo_emision)">
                      {{ row.tipo_emision }}
                    </span>
                  </td>
                  <td>{{ row.num_mercado }}</td>
                  <td class="text-center">
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-primary btn-sm" @click="modificarMercado(row)" title="Editar">
                        <font-awesome-icon icon="edit" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de Paginación -->
          <div v-if="mercados.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
                de {{ totalRecords }} registros
              </span>
            </div>

            <div class="pagination-size">
              <label class="municipal-form-label me-2">Registros por página:</label>
              <select class="municipal-form-control form-control-sm" :value="itemsPerPage"
                @change="changePageSize($event.target.value)" style="width: auto; display: inline-block;">
                <option value="5">5</option>
                <option value="10">10</option>
                <option value="25">25</option>
                <option value="50">50</option>
                <option value="100">100</option>
              </select>
            </div>

            <div class="pagination-buttons">
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(1)" :disabled="currentPage === 1"
                title="Primera página">
                <font-awesome-icon icon="angle-double-left" />
              </button>

              <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage - 1)"
                :disabled="currentPage === 1" title="Página anterior">
                <font-awesome-icon icon="angle-left" />
              </button>

              <button v-for="page in visiblePages" :key="page" class="btn-sm"
                :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
                @click="goToPage(page)">
                {{ page }}
              </button>

              <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage + 1)"
                :disabled="currentPage === totalPages" title="Página siguiente">
                <font-awesome-icon icon="angle-right" />
              </button>

              <button class="btn-municipal-secondary btn-sm" @click="goToPage(totalPages)"
                :disabled="currentPage === totalPages" title="Última página">
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal para Nuevo/Modificar Mercado -->
    <div v-if="showModal" class="modal-overlay" @click.self="cerrarModal">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <font-awesome-icon :icon="modalMode === 'nuevo' ? 'plus' : 'edit'" />
              {{ modalMode === 'nuevo' ? 'Agregar nuevo mercado' : 'Modificar mercado' }}
            </h5>
            <button type="button" class="btn-close" @click="cerrarModal"></button>
          </div>
          <div class="modal-body">
            <div class="form-row">
              <div class="form-group col-md-6">
                <label class="municipal-form-label">Oficina <span class="required">*</span></label>
                <select class="municipal-form-control" v-model.number="formData.oficina"
                  :disabled="modalMode === 'modificar' || loading">
                  <option value="">Seleccione...</option>
                  <option v-for="rec in recaudadoras" :key="rec.id_recaudadora" :value="rec.id_recaudadora">
                    {{ rec.id_recaudadora }} - {{ rec.descripcion }}
                  </option>
                </select>
              </div>
              <div class="form-group col-md-6">
                <label class="municipal-form-label">Mercado nuevo <span class="required">*</span></label>
                <input type="number" class="municipal-form-control" v-model.number="formData.num_mercado_nvo"
                  :disabled="modalMode === 'modificar'" />
              </div>
            </div>
            <div class="form-row">
              <div class="form-group col-md-6">
                <label class="municipal-form-label">Categoría <span class="required">*</span></label>
                <select class="municipal-form-control" v-model.number="formData.categoria" :disabled="loading">
                  <option value="">Seleccione...</option>
                  <option v-for="cat in categorias" :key="cat.categoria" :value="cat.categoria">
                    {{ cat.categoria }} - {{ cat.descripcion }}
                  </option>
                </select>
              </div>
              <div class="form-group col-md-6">
                <label class="municipal-form-label">Descripción <span class="required">*</span></label>
                <input type="text" class="municipal-form-control" v-model="formData.descripcion" maxlength="30"
                  style="text-transform: uppercase;" />
              </div>
            </div>
            <div class="form-row">
              <div class="form-group col-md-6">
                <label class="municipal-form-label">Cuenta ingreso <span class="required">*</span></label>
                <input type="number" class="municipal-form-control" v-model.number="formData.cuenta_ingreso" />
              </div>
              <div class="form-group col-md-6">
                <label class="municipal-form-label">Cuenta energía</label>
                <input type="number" class="municipal-form-control" v-model.number="formData.cuenta_energia" />
              </div>
            </div>
            <div class="form-row">
              <div class="form-group col-md-6">
                <label class="municipal-form-label">Zona <span class="required">*</span></label>
                <select class="municipal-form-control" v-model.number="formData.id_zona" :disabled="loading">
                  <option value="">Seleccione...</option>
                  <option v-for="zona in zonas" :key="zona.cvezona" :value="zona.cvezona">
                    {{ zona.cvezona }} - {{ zona.zona }}
                  </option>
                </select>
              </div>
              <div class="form-group col-md-6">
                <label class="municipal-form-label">Tipo Emisión <span class="required">*</span></label>
                <select class="municipal-form-control" v-model="formData.tipo_emision">
                  <option value="">Seleccione...</option>
                  <option value="A">A - Normal</option>
                  <option value="C">C - Comercial</option>
                  <option value="E">E - Especial</option>
                </select>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="cerrarModal">
              <font-awesome-icon icon="times" />
              Cancelar
            </button>
            <button type="button" class="btn-municipal-primary" @click="guardarMercado">
              <font-awesome-icon icon="save" />
              Guardar
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';
import Swal from 'sweetalert2';
import { useGlobalLoading } from '@/composables/useGlobalLoading';

export default {
  name: 'RecaudadorasMercados',
  setup() {
    const { showLoading, hideLoading } = useGlobalLoading();

    // Estado reactivo
    const loading = ref(false);
    const error = ref(null);
    const showFilters = ref(true);
    const searchPerformed = ref(false);

    // Datos
    const recaudadoras = ref([]);
    const mercados = ref([]);
    const zonas = ref([]);
    const categorias = ref([]);
    const selectedRec = ref('');

    // Paginación
    const currentPage = ref(1);
    const itemsPerPage = ref(10);

    // Modal
    const showModal = ref(false);
    const modalMode = ref('nuevo'); // 'nuevo' | 'modificar'
    const formData = ref({
      oficina: null,
      num_mercado_nvo: null,
      categoria: null,
      descripcion: '',
      cuenta_ingreso: null,
      cuenta_energia: null,
      id_zona: null,
      tipo_emision: '',
      num_mercado: null
    });

    // Computed
    const totalRecords = computed(() => mercados.value.length);
    const totalPages = computed(() => Math.ceil(totalRecords.value / itemsPerPage.value));

    const paginatedMercados = computed(() => {
      const start = (currentPage.value - 1) * itemsPerPage.value;
      const end = start + itemsPerPage.value;
      return mercados.value.slice(start, end);
    });

    const visiblePages = computed(() => {
      const pages = [];
      const maxVisible = 5;
      let startPage = Math.max(1, currentPage.value - Math.floor(maxVisible / 2));
      let endPage = Math.min(totalPages.value, startPage + maxVisible - 1);

      if (endPage - startPage < maxVisible - 1) {
        startPage = Math.max(1, endPage - maxVisible + 1);
      }

      for (let i = startPage; i <= endPage; i++) {
        pages.push(i);
      }

      return pages;
    });

    // Métodos - API Calls
    const fetchRecaudadoras = async () => {
      try {
        const response = await axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_get_recaudadoras',
            Base: 'padron_licencias',
            Parametros: []
          }
        });

        if (response.data?.eResponse?.success) {
          recaudadoras.value = response.data.eResponse.data.result || [];
        } else {
          throw new Error(response.data?.eResponse?.message || 'Error al obtener recaudadoras');
        }
      } catch (err) {
        console.error('Error fetchRecaudadoras:', err);
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: 'No se pudieron cargar las recaudadoras: ' + err.message
        });
      }
    };

    const fetchZonas = async () => {
      try {
        const response = await axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_get_zonas_all',
            Base: 'padron_licencias',
            Esquema: 'publico',
            Parametros: []
          }
        });

        if (response.data?.eResponse?.success) {
          zonas.value = response.data.eResponse.data.result || [];
        } else {
          throw new Error(response.data?.eResponse?.message || 'Error al obtener zonas');
        }
      } catch (err) {
        console.error('Error fetchZonas:', err);
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: 'No se pudieron cargar las zonas: ' + err.message
        });
      }
    };

    const fetchCategorias = async () => {
      try {
        const response = await axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_categoria_list',
            Base: 'mercados',
            Esquema: 'publico',
            Parametros: []
          }
        });

        if (response.data?.eResponse?.success) {
          categorias.value = response.data.eResponse.data.result || [];
        } else {
          throw new Error(response.data?.eResponse?.message || 'Error al obtener categorías');
        }
      } catch (err) {
        console.error('Error fetchCategorias:', err);
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: 'No se pudieron cargar las categorías: ' + err.message
        });
      }
    };

    const cargarCatalogo = async () => {
      loading.value = true;
      error.value = null;

      try {
        const nivelUsuario = 1; // TODO: Obtener del store de usuario
        const oficinaParam = selectedRec.value || null;

        const response = await axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_get_catalogo_mercados',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_oficina', tipo: 'integer', valor: oficinaParam },
              { nombre: 'p_nivel_usuario', tipo: 'integer', valor: nivelUsuario }
            ]
          }
        });

        if (response.data?.eResponse?.success) {
          mercados.value = response.data.eResponse.data.result || [];
          searchPerformed.value = true;
          currentPage.value = 1;

          if (mercados.value.length === 0) {
            Swal.fire({
              icon: 'info',
              title: 'Sin resultados',
              text: 'No se encontraron mercados con los criterios especificados'
            });
          }
        } else {
          throw new Error(response.data?.eResponse?.message || 'Error al obtener catálogo');
        }
      } catch (err) {
        console.error('Error cargarCatalogo:', err);
        error.value = err.message;
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: 'No se pudo cargar el catálogo de mercados: ' + err.message
        });
      } finally {
        loading.value = false;
      }
    };

    // Métodos - Filtros
    const onRecChange = () => {
      cargarCatalogo();
    };

    const limpiarFiltros = () => {
      selectedRec.value = '';
      mercados.value = [];
      searchPerformed.value = false;
      currentPage.value = 1;
    };

    const toggleFilters = () => {
      showFilters.value = !showFilters.value;
    };

    // Métodos - Paginación
    const goToPage = (page) => {
      if (page < 1 || page > totalPages.value) return;
      currentPage.value = page;
    };

    const changePageSize = (newSize) => {
      itemsPerPage.value = parseInt(newSize);
      currentPage.value = 1;
    };

    // Métodos - Modal
    const abrirModalNuevo = async () => {
      modalMode.value = 'nuevo';
      formData.value = {
        oficina: null,
        num_mercado_nvo: null,
        categoria: null,
        descripcion: '',
        cuenta_ingreso: null,
        cuenta_energia: null,
        id_zona: null,
        tipo_emision: '',
        num_mercado: null
      };

      // Cargar catálogos si no están cargados
      if (zonas.value.length === 0) {
        await fetchZonas();
      }
      if (categorias.value.length === 0) {
        await fetchCategorias();
      }

      showModal.value = true;
    };

    const modificarMercado = async (mercado) => {
      modalMode.value = 'modificar';
      formData.value = { ...mercado };

      // Cargar catálogos si no están cargados
      if (zonas.value.length === 0) {
        await fetchZonas();
      }
      if (categorias.value.length === 0) {
        await fetchCategorias();
      }

      showModal.value = true;
    };

    const cerrarModal = () => {
      showModal.value = false;
    };

    const guardarMercado = async () => {
      // Validar campos requeridos
      const camposFaltantes = [];

      if (!formData.value.oficina) camposFaltantes.push('Oficina');
      if (!formData.value.num_mercado_nvo) camposFaltantes.push('Mercado nuevo');
      if (!formData.value.categoria) camposFaltantes.push('Categoría');
      if (!formData.value.descripcion || formData.value.descripcion.trim() === '') camposFaltantes.push('Descripción');
      if (!formData.value.cuenta_ingreso) camposFaltantes.push('Cuenta ingreso');
      if (!formData.value.id_zona) camposFaltantes.push('Zona');
      if (!formData.value.tipo_emision) camposFaltantes.push('Tipo Emisión');

      if (camposFaltantes.length > 0) {
        console.log('❌ Validación fallida - Campos faltantes:', camposFaltantes);
        console.log('📋 Datos actuales del formulario:', JSON.stringify(formData.value, null, 2));

        const mensaje = `Faltan los siguientes campos: ${camposFaltantes.join(', ')}`;

        Swal.fire({
          icon: 'warning',
          title: 'Campos incompletos',
          text: mensaje
        });
        return;
      }

      console.log('✅ Validación exitosa - Guardando mercado');
      console.log('📋 Datos a enviar:', JSON.stringify(formData.value, null, 2));

      loading.value = true;

      try {
        const operacion = modalMode.value === 'nuevo' ? 'sp_create_catalogo_mercado' : 'sp_update_catalogo_mercado';

        const response = await axios.post('/api/generic', {
          eRequest: {
            Operacion: operacion,
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_oficina', tipo: 'smallint', valor: formData.value.oficina },
              { nombre: 'p_num_mercado_nvo', tipo: 'smallint', valor: formData.value.num_mercado_nvo },
              { nombre: 'p_categoria', tipo: 'smallint', valor: formData.value.categoria },
              { nombre: 'p_descripcion', tipo: 'varchar', valor: formData.value.descripcion },
              { nombre: 'p_cuenta_ingreso', tipo: 'integer', valor: formData.value.cuenta_ingreso },
              { nombre: 'p_cuenta_energia', tipo: 'integer', valor: formData.value.cuenta_energia || 0 },
              { nombre: 'p_id_zona', tipo: 'smallint', valor: formData.value.id_zona },
              { nombre: 'p_tipo_emision', tipo: 'varchar', valor: formData.value.tipo_emision },
              { nombre: 'p_usuario_id', tipo: 'integer', valor: 1 } // TODO: Obtener del store de usuario
            ]
          }
        });

        if (response.data?.eResponse?.success) {
          await Swal.fire({
            icon: 'success',
            title: '¡Éxito!',
            text: modalMode.value === 'nuevo'
              ? 'Mercado creado exitosamente'
              : 'Mercado actualizado exitosamente',
            timer: 2000,
            showConfirmButton: false
          });

          // Cerrar modal y recargar catálogo
          cerrarModal();
          await cargarCatalogo();
        } else {
          throw new Error(response.data?.eResponse?.message || 'Error al guardar el mercado');
        }
      } catch (err) {
        console.error('Error guardarMercado:', err);
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: 'No se pudo guardar el mercado: ' + err.message
        });
      } finally {
        loading.value = false;
      }
    };

    // Métodos - Utilidades
    const formatNumber = (value) => {
      if (value === null || value === undefined) return '0';
      return Number(value).toLocaleString('es-MX');
    };

    const getTipoEmisionClass = (tipo) => {
      const classes = {
        'A': 'bg-success',
        'C': 'bg-info',
        'E': 'bg-warning',
        'B': 'bg-secondary'
      };
      return classes[tipo] || 'bg-secondary';
    };

    const imprimirReporte = () => {
      Swal.fire({
        icon: 'info',
        title: 'Funcionalidad pendiente',
        text: 'La impresión de reportes está pendiente de implementación'
      });
    };

    const mostrarAyuda = () => {
      Swal.fire({
        icon: 'info',
        title: 'Ayuda - Catálogo de Recaudadoras y Mercados',
        html: `
          <div style="text-align: left;">
            <p><strong>Descripción:</strong></p>
            <p>Este módulo permite consultar y administrar el catálogo de mercados del sistema.</p>
            <br>
            <p><strong>Funciones:</strong></p>
            <ul>
              <li><strong>Agregar:</strong> Permite dar de alta un nuevo mercado</li>
              <li><strong>Editar:</strong> Use el botón de editar en cada fila para modificar un mercado</li>
              <li><strong>Imprimir:</strong> Genera un reporte del catálogo</li>
              <li><strong>Filtros:</strong> Permite filtrar por recaudadora</li>
            </ul>
            <br>
            <p><strong>Notas:</strong></p>
            <ul>
              <li>Seleccione una recaudadora para filtrar los mercados</li>
              <li>Use los controles de paginación para navegar entre registros</li>
              <li>Los mercados con tipo emisión "B" están ocultos</li>
            </ul>
          </div>
        `,
        width: 600
      });
    };

    // Lifecycle
    onMounted(async () => {
      showLoading('Cargando Catálogo de Mercados', 'Preparando recaudadoras y mercados...');
      try {
        await fetchRecaudadoras();
        await cargarCatalogo();
      } finally {
        hideLoading();
      }
    });

    return {
      // Estado
      loading,
      error,
      showFilters,
      searchPerformed,

      // Datos
      recaudadoras,
      mercados,
      zonas,
      categorias,
      selectedRec,

      // Paginación
      currentPage,
      itemsPerPage,
      totalRecords,
      totalPages,
      paginatedMercados,
      visiblePages,

      // Modal
      showModal,
      modalMode,
      formData,

      // Métodos
      fetchRecaudadoras,
      fetchZonas,
      fetchCategorias,
      cargarCatalogo,
      onRecChange,
      limpiarFiltros,
      toggleFilters,
      goToPage,
      changePageSize,
      abrirModalNuevo,
      modificarMercado,
      cerrarModal,
      guardarMercado,
      formatNumber,
      getTipoEmisionClass,
      imprimirReporte,
      mostrarAyuda
    };
  }
};
</script>

<style scoped>
.empty-icon {
  color: var(--color-municipal-secondary);
  opacity: 0.3;
  margin-bottom: 1rem;
}

.row-hover {
  transition: background-color 0.2s;
}

.row-hover:hover {
  background-color: rgba(var(--color-primary-rgb), 0.05);
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1050;
}

.modal-dialog {
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  max-width: 800px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  padding: 1.5rem;
  border-bottom: 1px solid #dee2e6;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-title {
  margin: 0;
  font-size: 1.25rem;
  color: var(--color-municipal-primary);
}

.modal-body {
  padding: 1.5rem;
}

.modal-footer {
  padding: 1rem 1.5rem;
  border-top: 1px solid #dee2e6;
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
}

.btn-close {
  background: transparent;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #6c757d;
}

.btn-close:hover {
  color: #000;
}

.required {
  color: #dc3545;
}

.badge {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
  font-weight: 600;
}
</style>
