<template>
  <div class="container-fluid py-4">
    <div class="municipal-card" style="min-height: 450px;">
      <div class="municipal-card-header">
        <h5 class="mb-0">Consulta de Datos Generales de Locales</h5>
      </div>
      <div class="municipal-card-body">
        <!-- Tipo de búsqueda -->
        <div class="mb-3">
          <div class="form-check form-check-inline">
            <input v-model="opcion" type="radio" class="form-check-input" value="L" id="opLocal">
            <label class="form-check-label" for="opLocal">Por Local</label>
          </div>
          <div class="form-check form-check-inline">
            <input v-model="opcion" type="radio" class="form-check-input" value="N" id="opNombre">
            <label class="form-check-label" for="opNombre">Por Nombre</label>
          </div>
        </div>

        <!-- Búsqueda por Local -->
        <div v-if="opcion === 'L'">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora</label>
              <select v-model="form.oficina" class="municipal-form-control" @change="onOficinaChange">
                <option value="">Seleccione</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                 {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Mercado</label>
              <select v-model="form.num_mercado" class="municipal-form-control">
                <option value="">Todos</option>
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                  {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Cat</label>
              <select v-model="form.categoria" class="municipal-form-control">
                <option value="">Todas</option>
                <option v-for="cat in categorias" :key="cat.categoria" :value="cat.categoria">
                  {{ cat.categoria }} - {{ cat.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Sección</label>
              <input v-model="form.seccion" type="text" class="municipal-form-control" maxlength="2" />
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Local</label>
              <input v-model="form.local" type="number" class="municipal-form-control" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Letra</label>
              <input v-model="form.letra_local" type="text" class="municipal-form-control" maxlength="3" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Bloque</label>
              <input v-model="form.bloque" type="text" class="municipal-form-control" maxlength="2" />
            </div>
          </div>
        </div>

        <!-- Búsqueda por Nombre -->
        <div v-if="opcion === 'N'">
          <div class="form-row">
            <div class="form-group" style="flex: 1;">
              <label class="municipal-form-label">Nombre</label>
              <input v-model="form.nombre" type="text" class="municipal-form-control" placeholder="Nombre del local o contribuyente" />
            </div>
          </div>
        </div>

        <!-- Botones -->
        <div class="mb-4">
          <button class="btn btn-municipal-primary btn-sm me-2" @click="buscar" :disabled="loading">
            <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
            Buscar
          </button>
          <button class="btn btn-outline-secondary btn-sm" @click="limpiar">Limpiar</button>
        </div>

        <!-- Resultados -->
        <div v-if="resultados.length" class="table-responsive">
          <table class="table table-sm table-striped table-hover municipal-table">
            <thead>
              <tr>
                <th>Control</th>
                <th>Rec</th>
                <th>Merc</th>
                <th>Cat</th>
                <th>Sección</th>
                <th>Local</th>
                <th>Letra</th>
                <th>Blq</th>
                <th>Nombre</th>
                <th>Acción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in paginatedData" :key="row.id_local">
                <td>{{ row.id_local }}</td>
                <td>{{ row.oficina }}</td>
                <td>{{ row.num_mercado }}</td>
                <td>{{ row.categoria }}</td>
                <td>{{ row.seccion }}</td>
                <td>{{ row.local }}</td>
                <td>{{ row.letra_local || '-' }}</td>
                <td>{{ row.bloque || '-' }}</td>
                <td>{{ row.nombre }}</td>
                <td>
                  <button class="btn btn-sm btn-outline-primary" @click="verIndividual(row.id_local)">Ver</button>
                </td>
              </tr>
            </tbody>
          </table>

          <!-- Controles de paginación -->
          <div v-if="resultados.length > 0" class="pagination-controls mt-3">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, resultados.length) }}
                de {{ resultados.length }} registros
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

        <!-- Detalle Individual -->
        <div v-if="individual" class="mt-4">
          <div class="municipal-card">
            <div class="municipal-card-header d-flex justify-content-between">
              <h6 class="mb-0">Datos Individuales del Local</h6>
              <button class="btn btn-sm btn-outline-secondary" @click="individual = null">Cerrar</button>
            </div>
            <div class="municipal-card-body">
              <div class="row">
                <div class="col-md-6">
                  <table class="table table-sm table-bordered">
                    <tr><th width="40%">ID Local</th><td>{{ individual.id_local }}</td></tr>
                    <tr><th>Nombre</th><td>{{ individual.nombre }}</td></tr>
                    <tr><th>Arrendatario</th><td>{{ individual.arrendatario || '-' }}</td></tr>
                    <tr><th>Domicilio</th><td>{{ individual.domicilio || '-' }}</td></tr>
                    <tr><th>Superficie</th><td>{{ individual.superficie }} m²</td></tr>
                    <tr><th>Giro</th><td>{{ individual.giro }}</td></tr>
                  </table>
                </div>
                <div class="col-md-6">
                  <table class="table table-sm table-bordered">
                    <tr><th width="40%">Vigencia</th><td>{{ individual.vigencia }}</td></tr>
                    <tr><th>Clave Cuota</th><td>{{ individual.clave_cuota }}</td></tr>
                    <tr><th>Fecha Alta</th><td>{{ formatDate(individual.fecha_alta) }}</td></tr>
                    <tr><th>Fecha Baja</th><td>{{ formatDate(individual.fecha_baja) || '-' }}</td></tr>
                    <tr><th>Actualización</th><td>{{ formatDate(individual.fecha_modificacion) }}</td></tr>
                    <tr><th>Sector/Zona</th><td>{{ individual.sector }} / {{ individual.zona }}</td></tr>
                  </table>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <DocumentationModal :show="showAyuda" :component-name="'ConsultaDatosLocales'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - ConsultaDatosLocales'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'ConsultaDatosLocales'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - ConsultaDatosLocales'" @close="showDocumentacion = false" />
</template>

<script setup>
import apiService from '@/services/apiService';
import { ref, computed, onMounted } from 'vue';
import { useGlobalLoading } from '@/composables/useGlobalLoading';
import { useToast } from '@/composables/useToast';
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


const { showLoading, hideLoading } = useGlobalLoading();
const { showToast } = useToast();

const loading = ref(false);
const opcion = ref('');
const recaudadoras = ref([]);
const mercados = ref([]);
const categorias = ref([]);
const resultados = ref([]);
const individual = ref(null);

// Paginación
const currentPage = ref(1);
const itemsPerPage = ref(10);

const form = ref({
  oficina: '',
  num_mercado: '',
  categoria: '',
  seccion: '',
  local: '',
  letra_local: '',
  bloque: '',
  nombre: ''
});

const formatDate = (value) => {
  if (!value) return '';
  return new Date(value).toLocaleDateString('es-MX');
};

// Computed para paginación
const totalPages = computed(() => {
  return Math.ceil(resultados.value.length / itemsPerPage.value);
});

const paginatedData = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value;
  const end = start + itemsPerPage.value;
  return resultados.value.slice(start, end);
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

// Métodos de paginación
const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page;
  }
};

const changePageSize = (newSize) => {
  itemsPerPage.value = parseInt(newSize);
  currentPage.value = 1;
};

const fetchRecaudadoras = async () => {
  try {
    const response = await apiService.execute(
          'sp_get_recaudadoras',
          'mercados',
          [],
          '',
          null,
          'publico'
        );
    if (response?.success) {
      recaudadoras.value = response.data.result || [];
    }
  } catch (error) {
    console.error('Error al cargar recaudadoras:', error);
  }
};

const fetchCategorias = async () => {
  try {
    const response = await apiService.execute(
          'sp_categoria_list',
          'mercados',
          [],
          '',
          null,
          'publico'
        );
    if (response?.success) {
      categorias.value = response.data.result || [];
    }
  } catch (error) {
    console.error('Error al cargar categorías:', error);
  }
};

const onOficinaChange = async () => {
  mercados.value = [];
  form.value.num_mercado = '';
  if (!form.value.oficina) return;

  try {
    const response = await apiService.execute(
          'sp_consulta_locales_get_mercados',
          'mercados',
          [
          { nombre: 'p_oficina', valor: parseInt(form.value.oficina) }
        ],
          '',
          null,
          'publico'
        );
    if (response?.success) {
      mercados.value = response.data.result || [];
    }
  } catch (error) {
    console.error('Error al cargar mercados:', error);
  }
};

const buscar = async () => {
  if (!opcion.value) {
    showToast('Seleccione un tipo de búsqueda', 'warning');
    return;
  }

  loading.value = true;
  resultados.value = [];
  individual.value = null;

  try {
    if (opcion.value === 'L') {
      const response = await apiService.execute(
          'sp_consulta_locales_buscar',
          'mercados',
          [
            { nombre: 'p_oficina', valor: form.value.oficina ? parseInt(form.value.oficina) : null },
            { nombre: 'p_num_mercado', valor: form.value.num_mercado ? parseInt(form.value.num_mercado) : null },
            { nombre: 'p_categoria', valor: form.value.categoria ? parseInt(form.value.categoria) : null },
            { nombre: 'p_seccion', valor: form.value.seccion || null },
            { nombre: 'p_local', valor: form.value.local ? parseInt(form.value.local) : null },
            { nombre: 'p_letra_local', valor: form.value.letra_local || null },
            { nombre: 'p_bloque', valor: form.value.bloque || null }
          ],
          '',
          null,
          'publico'
        );
      if (response?.success) {
        resultados.value = response.data.result || [];
        currentPage.value = 1; // Resetear a la primera página
        if (resultados.value.length === 0) {
          showToast('No se encontraron locales con los criterios especificados', 'info');
        }
      }
    } else if (opcion.value === 'N') {
      if (!form.value.nombre) {
        showToast('Ingrese un nombre para buscar', 'warning');
        loading.value = false;
        return;
      }
      const response = await apiService.execute(
          'sp_consulta_locales_buscar_nombre',
          'mercados',
          [
            { nombre: 'p_nombre', valor: form.value.nombre }
          ],
          '',
          null,
          'publico'
        );
      if (response?.success) {
        resultados.value = response.data.result || [];
        currentPage.value = 1; // Resetear a la primera página
        if (resultados.value.length === 0) {
          showToast('No se encontraron locales con el nombre especificado', 'info');
        }
      }
    }
  } catch (error) {
    console.error('Error al buscar:', error);
    showToast('Error al buscar locales', 'error');
  } finally {
    loading.value = false;
  }
};

const verIndividual = async (id_local) => {
  try {
    const response = await apiService.execute(
          'sp_consulta_locales_get_individual',
          'mercados',
          [
          { nombre: 'p_id_local', valor: id_local }
        ],
          '',
          null,
          'publico'
        );
    if (response?.success) {
      const result = response.data.result || [];
      individual.value = result[0] || null;
    }
  } catch (error) {
    console.error('Error al cargar detalle:', error);
  }
};

const limpiar = () => {
  form.value = {
    oficina: '',
    num_mercado: '',
    categoria: '',
    seccion: '',
    local: '',
    letra_local: '',
    bloque: '',
    nombre: ''
  };
  resultados.value = [];
  individual.value = null;
  opcion.value = '';
  mercados.value = [];
};

onMounted(async () => {
  showLoading('Cargando Consulta de Datos de Locales', 'Preparando oficinas recaudadoras...');
  try {
    await Promise.all([fetchRecaudadoras(), fetchCategorias()]);
  } finally {
    hideLoading();
  }
});
</script>
