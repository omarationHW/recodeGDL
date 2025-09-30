<template>
  <div class="municipal-form-page">
    <!-- Municipal Header -->
    <div class="municipal-header">
      <div class="row align-items-center">
        <div class="col">
          <h1>
            <i class="fas fa-file-contract"></i>
            Consulta de Licencias
          </h1>
          <p class="mb-0">
            Sistema de consulta y gestión de licencias municipales
          </p>
        </div>
      </div>
    </div>

    <nav aria-label="breadcrumb" class="municipal-breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><a href="#" class="text-decoration-none">Inicio</a></li>
        <li class="breadcrumb-item"><a href="#" class="text-decoration-none">Licencias</a></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta</li>
      </ol>
    </nav>

    <div class="municipal-card mb-4">
      <div class="municipal-card-header">
        <h5 class="mb-0">
          <i class="fas fa-search"></i>
          Búsqueda de Licencias
        </h5>
      </div>
      <div class="municipal-card-body">
        <form @submit.prevent="buscar">
          <div class="row g-3">
            <div class="col-md-6">
              <label class="municipal-form-label">
                <i class="fas fa-id-card"></i> No. Licencia:
              </label>
              <div class="input-group">
                <input v-model="form.licencia" type="text" class="municipal-form-control" placeholder="Ingrese número de licencia" />
                <button type="button" @click="buscarPor('licencia')" class="btn-municipal-primary">
                  <i class="fas fa-search"></i>
                </button>
              </div>
            </div>
            <div class="col-md-6">
              <label class="municipal-form-label">
                <i class="fas fa-map-marker-alt"></i> Ubicación:
              </label>
              <div class="input-group">
                <input v-model="form.ubicacion" type="text" class="municipal-form-control" placeholder="Ingrese ubicación" />
                <button type="button" @click="buscarPor('ubicacion')" class="btn-municipal-primary">
                  <i class="fas fa-search"></i>
                </button>
              </div>
            </div>
          </div>
          <div class="row g-3 mt-2">
            <div class="col-md-6">
              <label class="municipal-form-label">
                <i class="fas fa-user"></i> Contribuyente:
              </label>
              <div class="input-group">
                <input v-model="form.propietario" type="text" class="municipal-form-control" placeholder="Nombre del contribuyente" />
                <button type="button" @click="buscarPor('contribuyente')" class="btn-municipal-primary">
                  <i class="fas fa-search"></i>
                </button>
              </div>
            </div>
            <div class="col-md-6">
              <label class="municipal-form-label">
                <i class="fas fa-file-alt"></i> No. Trámite:
              </label>
              <div class="input-group">
                <input v-model="form.id_tramite" type="text" class="municipal-form-control" placeholder="Número de trámite" />
                <button type="button" @click="buscarPor('tramite')" class="btn-municipal-primary">
                  <i class="fas fa-search"></i>
                </button>
              </div>
            </div>
          </div>
        </form>
      </div>
    </div>

    <!-- Municipal Results Section -->
    <div v-if="resultados.length" class="municipal-card">
      <div class="municipal-card-header">
        <h5 class="mb-0">
          <i class="fas fa-table"></i>
          Resultados de la Búsqueda
          <span class="badge bg-light text-dark ms-2">{{ resultados.length }}</span>
        </h5>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table municipal-table mb-0">
            <thead>
              <tr>
                <th><i class="fas fa-id-card me-1"></i>Licencia</th>
                <th><i class="fas fa-user me-1"></i>Propietario</th>
                <th><i class="fas fa-map-marker-alt me-1"></i>Ubicación</th>
                <th><i class="fas fa-briefcase me-1"></i>Actividad</th>
                <th><i class="fas fa-calendar-check me-1"></i>Vigencia</th>
                <th><i class="fas fa-lock me-1"></i>Bloqueado</th>
                <th><i class="fas fa-cogs me-1"></i>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="lic in resultados" :key="lic.id_licencia" class="municipal-selected">
                <td><strong class="text-primary">{{ lic.licencia }}</strong></td>
                <td>{{ lic.propietario }}</td>
                <td>{{ lic.ubicacion }}</td>
                <td>{{ lic.actividad }}</td>
                <td>
                  <span class="badge" :class="lic.vigente ? 'bg-success' : 'bg-warning'">
                    {{ lic.vigente ? 'Vigente' : 'No Vigente' }}
                  </span>
                </td>
                <td>
                  <span class="badge" :class="lic.bloqueado ? 'bg-danger' : 'bg-success'">
                    {{ lic.bloqueado ? 'Sí' : 'No' }}
                  </span>
                </td>
                <td>
                  <div class="btn-group btn-group-sm municipal-group-btn" role="group">
                    <button @click="verDetalle(lic)" class="btn btn-outline-info municipal-btn-info" title="Ver detalles">
                      <i class="fas fa-eye"></i>
                    </button>
                    <button v-if="!lic.bloqueado" @click="bloquear(lic)" class="btn btn-outline-danger municipal-btn-danger" title="Bloquear">
                      <i class="fas fa-lock"></i>
                    </button>
                    <button v-if="lic.bloqueado" @click="desbloquear(lic)" class="btn btn-outline-success municipal-btn-success" title="Desbloquear">
                      <i class="fas fa-unlock"></i>
                    </button>
                    <button @click="verPagos(lic)" class="btn btn-outline-primary municipal-btn-primary" title="Ver pagos">
                      <i class="fas fa-money-bill-wave"></i>
                    </button>
                    <button @click="verAdeudos(lic)" class="btn btn-outline-warning municipal-btn-warning" title="Ver adeudos">
                      <i class="fas fa-exclamation-triangle"></i>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="card-footer municipal-card-footer">
        <button @click="exportarExcel" class="btn btn-success municipal-btn-success">
          <i class="fas fa-file-excel"></i>
          Exportar a Excel
        </button>
      </div>
    </div>
    <section v-if="detalle">
      <h2>Detalle de Licencia</h2>
      <div class="detalle-grid">
        <div><strong>Licencia:</strong> {{ detalle.licencia }}</div>
        <div><strong>Propietario:</strong> {{ detalle.propietario }}</div>
        <div><strong>Ubicación:</strong> {{ detalle.ubicacion }}</div>
        <div><strong>Actividad:</strong> {{ detalle.actividad }}</div>
        <div><strong>Vigencia:</strong> {{ detalle.vigente }}</div>
        <div><strong>Bloqueado:</strong> {{ detalle.bloqueado ? 'Sí' : 'No' }}</div>
        <div><strong>Correo:</strong> {{ detalle.email }}</div>
        <div><strong>Teléfono:</strong> {{ detalle.telefono_prop }}</div>
        <div><strong>Zona:</strong> {{ detalle.zona }}</div>
        <div><strong>Subzona:</strong> {{ detalle.subzona }}</div>
        <div><strong>Fecha de Otorgamiento:</strong> {{ detalle.fecha_otorgamiento }}</div>
        <div><strong>Fecha de Baja:</strong> {{ detalle.fecha_baja }}</div>
      </div>
      <button @click="detalle = null">Cerrar</button>
    </section>
    <section v-if="pagos.length">
      <h2>Pagos</h2>
      <table class="result-table">
        <thead>
          <tr>
            <th>Fecha</th>
            <th>Importe</th>
            <th>Cajero</th>
            <th>Folio</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in pagos" :key="p.cvepago">
            <td>{{ p.fecha }}</td>
            <td>{{ p.importe }}</td>
            <td>{{ p.cajero }}</td>
            <td>{{ p.folio }}</td>
          </tr>
        </tbody>
      </table>
      <button @click="pagos = []">Cerrar</button>
    </section>
    <section v-if="adeudos.length">
      <h2>Adeudos</h2>
      <table class="result-table">
        <thead>
          <tr>
            <th>Año</th>
            <th>Derechos</th>
            <th>Recargos</th>
            <th>Formas</th>
            <th>Saldo</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="a in adeudos" :key="a.axo">
            <td>{{ a.axo }}</td>
            <td>{{ a.derechos }}</td>
            <td>{{ a.recargos }}</td>
            <td>{{ a.formas }}</td>
            <td>{{ a.saldo }}</td>
          </tr>
        </tbody>
      </table>
      <button @click="adeudos = []">Cerrar</button>
    </section>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'ConsultaLicenciaPage',
  data() {
    return {
      form: {
        licencia: '',
        ubicacion: '',
        propietario: '',
        id_tramite: ''
      },
      resultados: [],
      detalle: null,
      pagos: [],
      adeudos: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    async buscarPor(tipo) {
      this.loading = true;
      this.error = '';
      let operation = '';
      let params = {};
      if (tipo === 'licencia') {
        operation = 'search_by_licencia';
        params = { licencia: this.form.licencia };
      } else if (tipo === 'ubicacion') {
        operation = 'search_by_ubicacion';
        params = { ubicacion: this.form.ubicacion };
      } else if (tipo === 'contribuyente') {
        operation = 'search_by_contribuyente';
        params = { propietario: this.form.propietario };
      } else if (tipo === 'tramite') {
        operation = 'search_by_tramite';
        params = { id_tramite: this.form.id_tramite };
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { operation, params }
        });
        if (res.data.eResponse.error) {
          this.error = res.data.eResponse.error;
          this.resultados = [];
        } else {
          this.resultados = res.data.eResponse.result;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    buscar() {
      // Por defecto busca por licencia
      this.buscarPor('licencia');
    },
    verDetalle(lic) {
      this.detalle = lic;
    },
    async verPagos(lic) {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { operation: 'get_pagos', params: { id_licencia: lic.id_licencia } }
        });
        if (res.data.eResponse.error) {
          this.error = res.data.eResponse.error;
          this.pagos = [];
        } else {
          this.pagos = res.data.eResponse.result;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async verAdeudos(lic) {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { operation: 'get_adeudos', params: { id_licencia: lic.id_licencia, tipo: 'L' } }
        });
        if (res.data.eResponse.error) {
          this.error = res.data.eResponse.error;
          this.adeudos = [];
        } else {
          this.adeudos = res.data.eResponse.result;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async bloquear(lic) {
      const motivo = prompt('Motivo del bloqueo:');
      if (!motivo) return;
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { operation: 'bloquear_licencia', params: { id_licencia: lic.id_licencia, tipo_bloqueo: 1, motivo } }
        });
        if (res.data.eResponse.error) {
          this.error = res.data.eResponse.error;
        } else {
          alert('Licencia bloqueada');
          this.buscar();
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async desbloquear(lic) {
      const motivo = prompt('Motivo del desbloqueo:');
      if (!motivo) return;
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { operation: 'desbloquear_licencia', params: { id_licencia: lic.id_licencia, tipo_bloqueo: 1, motivo } }
        });
        if (res.data.eResponse.error) {
          this.error = res.data.eResponse.error;
        } else {
          alert('Licencia desbloqueada');
          this.buscar();
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async exportarExcel() {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { operation: 'exportar_excel', params: { filtros: this.form } }
        });
        if (res.data.eResponse.error) {
          this.error = res.data.eResponse.error;
        } else {
          // Suponiendo que el backend regresa una URL de descarga
          window.open(res.data.eResponse.result.url, '_blank');
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

