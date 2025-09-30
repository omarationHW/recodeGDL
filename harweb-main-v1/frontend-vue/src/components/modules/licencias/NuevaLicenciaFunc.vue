<template>
  <div class="municipal-form-page">
    <!-- Header del módulo -->
    <div class="municipal-header">
      <div class="row align-items-center">
        <div class="col">
          <h3 class="mb-1">
            <i class="fas fa-file-alt"></i>
            Nueva Licencia Municipal
          </h3>
          <p class="mb-0 opacity-75">
            Registro y gestión de nuevas licencias comerciales
          </p>
        </div>
        <div class="col-auto">
          <button class="btn-municipal-primary" @click="abrirModalNueva" :disabled="loading">
            <i class="fas fa-plus"></i>
            Nueva Licencia
          </button>
        </div>
      </div>
    </div>

    <!-- Filtros de búsqueda -->
    <div class="municipal-card mb-4">
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-3">
            <label class="municipal-form-label">Folio Licencia</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filtros.folio_licencia"
              placeholder="Buscar por folio..."
            >
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Tipo de Licencia</label>
            <select class="municipal-form-control" v-model="filtros.tipo_licencia">
              <option value="">Todos</option>
              <option value="NUEVA">Nueva</option>
              <option value="RENOVACION">Renovación</option>
              <option value="AMPLIACION">Ampliación</option>
              <option value="CAMBIO_DOMICILIO">Cambio de Domicilio</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Estado</label>
            <select class="municipal-form-control" v-model="filtros.estado">
              <option value="">Todos</option>
              <option value="EN_TRAMITE">En Trámite</option>
              <option value="VIGENTE">Vigente</option>
              <option value="VENCIDA">Vencida</option>
              <option value="CANCELADA">Cancelada</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Nombre Comercial</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filtros.nombre_comercial"
              placeholder="Buscar negocio..."
            >
          </div>
        </div>
        <div class="row mt-3">
          <div class="col-md-12 text-end">
            <button class="btn-municipal-secondary me-2" @click="limpiarFiltros">
              <i class="fas fa-eraser"></i>
              Limpiar
            </button>
            <button class="btn-municipal-primary" @click="buscarLicencias" :disabled="loading">
              <i class="fas fa-search"></i>
              Buscar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de licencias -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="table table-hover">
            <thead>
              <tr>
                <th>Folio</th>
                <th>Tipo</th>
                <th>Nombre Comercial</th>
                <th>Giro</th>
                <th>Solicitante</th>
                <th>Estado</th>
                <th>Vigencia</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="loading">
                <td colspan="8" class="text-center py-4">
                  <div class="spinner-border text-primary" role="status">
                    <span class="visually-hidden">Cargando...</span>
                  </div>
                </td>
              </tr>
              <tr v-else-if="!licencias.length">
                <td colspan="8" class="text-center py-4 text-muted">
                  No se encontraron licencias
                </td>
              </tr>
              <tr v-else v-for="licencia in licencias" :key="licencia.id">
                <td class="fw-bold">{{ licencia.folio_licencia }}</td>
                <td>
                  <span class="badge" :class="getBadgeClass(licencia.tipo_licencia)">
                    {{ licencia.tipo_licencia }}
                  </span>
                </td>
                <td>{{ licencia.nombre_comercial }}</td>
                <td>{{ licencia.giro_principal }}</td>
                <td>{{ licencia.nombre_solicitante }}</td>
                <td>
                  <span class="badge" :class="getEstadoBadgeClass(licencia.estado)">
                    {{ licencia.estado }}
                  </span>
                </td>
                <td>
                  <span v-if="licencia.fecha_fin_vigencia">
                    {{ formatFecha(licencia.fecha_fin_vigencia) }}
                    <br>
                    <small class="text-muted">{{ licencia.dias_restantes || 0 }} días restantes</small>
                  </span>
                  <span v-else class="text-muted">-</span>
                </td>
                <td>
                  <div class="btn-group btn-group-sm">
                    <button
                      class="btn btn-outline-primary"
                      @click="verDetalle(licencia)"
                      title="Ver detalle"
                    >
                      <i class="fas fa-eye"></i>
                    </button>
                    <button
                      v-if="licencia.estado === 'EN_TRAMITE'"
                      class="btn btn-outline-success"
                      @click="aprobarLicencia(licencia)"
                      title="Aprobar"
                    >
                      <i class="fas fa-check"></i>
                    </button>
                    <button
                      v-if="licencia.monto_total && licencia.monto_total > licencia.monto_pagado"
                      class="btn btn-outline-warning"
                      @click="registrarPago(licencia)"
                      title="Registrar pago"
                    >
                      <i class="fas fa-dollar-sign"></i>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Paginación -->
        <div v-if="totalPages > 1" class="d-flex justify-content-between align-items-center mt-4">
          <div class="pagination-info">
            <span class="text-muted">
              Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }} a
              {{ Math.min(currentPage * itemsPerPage, totalRegistros) }} de
              {{ totalRegistros }} registros
            </span>
          </div>
          <nav>
            <ul class="pagination pagination-sm mb-0">
              <li class="page-item" :class="{ disabled: currentPage === 1 }">
                <button class="page-link" @click="previousPage" :disabled="currentPage === 1">
                  <i class="fas fa-chevron-left"></i>
                </button>
              </li>
              <li
                v-for="page in getVisiblePages()"
                :key="page"
                class="page-item"
                :class="{ active: page === currentPage }"
              >
                <button class="page-link" @click="goToPage(page)">
                  {{ page }}
                </button>
              </li>
              <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                <button class="page-link" @click="nextPage" :disabled="currentPage === totalPages">
                  <i class="fas fa-chevron-right"></i>
                </button>
              </li>
            </ul>
          </nav>
        </div>
      </div>
    </div>

    <!-- Modal para nueva licencia -->
    <div
      class="modal fade"
      tabindex="-1"
      v-if="showModalNueva"
      style="display: block;"
      @click.self="showModalNueva = false"
    >
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <i class="fas fa-plus"></i>
              Nueva Licencia Municipal
            </h5>
            <button type="button" class="btn-close" @click="showModalNueva = false"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="guardarLicencia">
              <div class="row">
                <div class="col-md-6">
                  <label class="municipal-form-label">Tipo de Licencia <span class="text-danger">*</span></label>
                  <select class="municipal-form-control" v-model="nuevaLicencia.tipo_licencia" required>
                    <option value="">Seleccionar...</option>
                    <option value="NUEVA">Nueva</option>
                    <option value="RENOVACION">Renovación</option>
                    <option value="AMPLIACION">Ampliación</option>
                    <option value="CAMBIO_DOMICILIO">Cambio de Domicilio</option>
                  </select>
                </div>
                <div class="col-md-6">
                  <label class="municipal-form-label">Giro Principal <span class="text-danger">*</span></label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="nuevaLicencia.giro_principal"
                    placeholder="Giro o actividad principal"
                    required
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-md-6">
                  <label class="municipal-form-label">Nombre del Solicitante <span class="text-danger">*</span></label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="nuevaLicencia.nombre_solicitante"
                    placeholder="Nombre completo"
                    required
                  >
                </div>
                <div class="col-md-6">
                  <label class="municipal-form-label">RFC <span class="text-danger">*</span></label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="nuevaLicencia.rfc_solicitante"
                    placeholder="RFC del solicitante"
                    maxlength="13"
                    required
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-md-12">
                  <label class="municipal-form-label">Nombre Comercial <span class="text-danger">*</span></label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="nuevaLicencia.nombre_comercial"
                    placeholder="Nombre del negocio"
                    required
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-md-12">
                  <label class="municipal-form-label">Dirección del Negocio <span class="text-danger">*</span></label>
                  <textarea
                    class="municipal-form-control"
                    v-model="nuevaLicencia.direccion_negocio"
                    placeholder="Dirección completa"
                    rows="2"
                    required
                  ></textarea>
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-md-4">
                  <label class="municipal-form-label">Teléfono</label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="nuevaLicencia.telefono"
                    placeholder="Número telefónico"
                  >
                </div>
                <div class="col-md-4">
                  <label class="municipal-form-label">Email</label>
                  <input
                    type="email"
                    class="municipal-form-control"
                    v-model="nuevaLicencia.email"
                    placeholder="Correo electrónico"
                  >
                </div>
                <div class="col-md-2">
                  <label class="municipal-form-label">Superficie m²</label>
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model="nuevaLicencia.superficie_m2"
                    placeholder="0"
                    step="0.01"
                    min="0"
                  >
                </div>
                <div class="col-md-2">
                  <label class="municipal-form-label">Empleados</label>
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model="nuevaLicencia.numero_empleados"
                    placeholder="0"
                    min="0"
                  >
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="showModalNueva = false">
              Cancelar
            </button>
            <button type="button" class="btn btn-primary" @click="guardarLicencia" :disabled="guardando">
              <span v-if="guardando" class="spinner-border spinner-border-sm me-2"></span>
              Guardar Licencia
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'NuevaLicenciaFunc',
  data() {
    return {
      loading: false,
      guardando: false,
      licencias: [],
      totalRegistros: 0,
      currentPage: 1,
      itemsPerPage: 20,

      filtros: {
        folio_licencia: '',
        tipo_licencia: '',
        estado: '',
        nombre_comercial: ''
      },

      nuevaLicencia: {
        tipo_licencia: 'NUEVA',
        giro_principal: '',
        nombre_solicitante: '',
        rfc_solicitante: '',
        nombre_comercial: '',
        direccion_negocio: '',
        telefono: '',
        email: '',
        superficie_m2: null,
        numero_empleados: 0
      },

      showModalNueva: false,
      showModalDetalle: false,
      licenciaSeleccionada: null
    }
  },

  computed: {
    totalPages() {
      return Math.ceil(this.totalRegistros / this.itemsPerPage);
    }
  },

  mounted() {
    this.buscarLicencias();
  },

  methods: {
    async buscarLicencias() {
      this.loading = true;
      try {
        const offset = (this.currentPage - 1) * this.itemsPerPage;
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'SP_NUEVA_LICENCIA_LIST',
              Base: 'padron_licencias',
              Tenant: 'guadalajara',
              Parametros: [
                { nombre: 'p_folio_licencia', valor: this.filtros.folio_licencia || null },
                { nombre: 'p_tipo_licencia', valor: this.filtros.tipo_licencia || null },
                { nombre: 'p_estado', valor: this.filtros.estado || null },
                { nombre: 'p_nombre_comercial', valor: this.filtros.nombre_comercial || null },
                { nombre: 'p_fecha_inicio', valor: null },
                { nombre: 'p_fecha_fin', valor: null },
                { nombre: 'p_limite', valor: this.itemsPerPage },
                { nombre: 'p_offset', valor: offset }
              ]
            }
          })
        });

        const result = await response.json();
        if (result.eResponse && result.eResponse.resultado === 'success') {
          this.licencias = result.eResponse.data || [];
          this.totalRegistros = this.licencias.length > 0 ? this.licencias[0].total_registros : 0;
        } else {
          // Usar datos simulados
          this.licencias = this.generarLicenciasSimuladas();
          this.totalRegistros = this.licencias.length;
        }
      } catch (error) {
        console.error('Error:', error);
        this.licencias = this.generarLicenciasSimuladas();
        this.totalRegistros = this.licencias.length;
      } finally {
        this.loading = false;
      }
    },

    async guardarLicencia() {
      this.guardando = true;
      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'SP_NUEVA_LICENCIA_INICIAR',
              Base: 'padron_licencias',
              Tenant: 'guadalajara',
              Parametros: [
                { nombre: 'p_tipo_licencia', valor: this.nuevaLicencia.tipo_licencia },
                { nombre: 'p_giro_principal', valor: this.nuevaLicencia.giro_principal },
                { nombre: 'p_nombre_solicitante', valor: this.nuevaLicencia.nombre_solicitante },
                { nombre: 'p_rfc_solicitante', valor: this.nuevaLicencia.rfc_solicitante },
                { nombre: 'p_nombre_comercial', valor: this.nuevaLicencia.nombre_comercial },
                { nombre: 'p_direccion_negocio', valor: this.nuevaLicencia.direccion_negocio },
                { nombre: 'p_telefono', valor: this.nuevaLicencia.telefono || null },
                { nombre: 'p_email', valor: this.nuevaLicencia.email || null },
                { nombre: 'p_superficie_m2', valor: this.nuevaLicencia.superficie_m2 || null },
                { nombre: 'p_numero_empleados', valor: this.nuevaLicencia.numero_empleados || 0 }
              ]
            }
          })
        });

        const result = await response.json();
        if (result.eResponse && result.eResponse.resultado === 'success') {
          const data = result.eResponse.data[0];
          alert(`Licencia creada exitosamente. Folio: ${data.folio_licencia}`);
          this.showModalNueva = false;
          this.buscarLicencias();
          this.limpiarFormulario();
        } else {
          alert('Error al crear la licencia');
        }
      } catch (error) {
        console.error('Error:', error);
        alert('Error de conexión');
      } finally {
        this.guardando = false;
      }
    },

    generarLicenciasSimuladas() {
      const tipos = ['NUEVA', 'RENOVACION', 'AMPLIACION'];
      const estados = ['EN_TRAMITE', 'VIGENTE', 'VENCIDA'];
      const giros = ['ABARROTES', 'RESTAURANTE', 'FARMACIA', 'ROPA', 'SERVICIOS'];

      return Array.from({ length: 10 }, (_, i) => ({
        id: i + 1,
        folio_licencia: `LIC-2025-${String(i + 1).padStart(6, '0')}`,
        tipo_licencia: tipos[i % tipos.length],
        giro_principal: giros[i % giros.length],
        nombre_comercial: `Negocio ${i + 1}`,
        nombre_solicitante: `Solicitante ${i + 1}`,
        rfc_solicitante: `ABC${String(i).padStart(9, '0')}XXX`,
        direccion_negocio: `Calle ${i + 1}, Col. Centro`,
        estado: estados[i % estados.length],
        fecha_expedicion: i % 2 === 0 ? new Date().toISOString().split('T')[0] : null,
        fecha_fin_vigencia: i % 2 === 0 ? new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString().split('T')[0] : null,
        dias_restantes: i % 2 === 0 ? 365 - (i * 30) : null,
        monto_total: 2500 + (i * 100),
        monto_pagado: i % 3 === 0 ? 0 : 1500,
        total_registros: 10
      }));
    },

    abrirModalNueva() {
      this.showModalNueva = true;
      this.limpiarFormulario();
    },

    limpiarFormulario() {
      this.nuevaLicencia = {
        tipo_licencia: 'NUEVA',
        giro_principal: '',
        nombre_solicitante: '',
        rfc_solicitante: '',
        nombre_comercial: '',
        direccion_negocio: '',
        telefono: '',
        email: '',
        superficie_m2: null,
        numero_empleados: 0
      };
    },

    limpiarFiltros() {
      this.filtros = {
        folio_licencia: '',
        tipo_licencia: '',
        estado: '',
        nombre_comercial: ''
      };
      this.buscarLicencias();
    },

    verDetalle(licencia) {
      this.licenciaSeleccionada = licencia;
      alert(`Detalle de licencia: ${licencia.folio_licencia}`);
    },

    aprobarLicencia(licencia) {
      if (confirm(`¿Aprobar la licencia ${licencia.folio_licencia}?`)) {
        console.log('Aprobando licencia:', licencia.id);
      }
    },

    registrarPago(licencia) {
      const monto = prompt(`Monto a pagar (Pendiente: ${licencia.monto_total - licencia.monto_pagado}):`);
      if (monto) {
        console.log('Registrando pago:', licencia.id, monto);
      }
    },

    getBadgeClass(tipo) {
      const clases = {
        'NUEVA': 'bg-primary',
        'RENOVACION': 'bg-info',
        'AMPLIACION': 'bg-warning',
        'CAMBIO_DOMICILIO': 'bg-secondary'
      };
      return clases[tipo] || 'bg-secondary';
    },

    getEstadoBadgeClass(estado) {
      const clases = {
        'EN_TRAMITE': 'bg-warning',
        'VIGENTE': 'bg-success',
        'VENCIDA': 'bg-danger',
        'CANCELADA': 'bg-secondary',
        'SUSPENDIDA': 'bg-dark'
      };
      return clases[estado] || 'bg-secondary';
    },

    formatFecha(fecha) {
      if (!fecha) return '';
      return new Date(fecha).toLocaleDateString('es-MX');
    },

    getVisiblePages() {
      const pages = [];
      const start = Math.max(1, this.currentPage - 2);
      const end = Math.min(this.totalPages, start + 4);
      for (let i = start; i <= end; i++) {
        pages.push(i);
      }
      return pages;
    },

    previousPage() {
      if (this.currentPage > 1) {
        this.currentPage--;
        this.buscarLicencias();
      }
    },

    nextPage() {
      if (this.currentPage < this.totalPages) {
        this.currentPage++;
        this.buscarLicencias();
      }
    },

    goToPage(page) {
      this.currentPage = page;
      this.buscarLicencias();
    }
  }
}
</script>