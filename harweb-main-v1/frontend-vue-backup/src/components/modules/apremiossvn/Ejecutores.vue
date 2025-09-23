<template>
  <div class="ejecutores-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta del Ejecutor</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-body">
        <form @submit.prevent>
          <div class="row">
            <div class="col-md-8">
              <label for="nombre" class="form-label">Nombre</label>
              <input
                id="nombre"
                v-model="filters.nombre"
                @keyup="buscarPorNombre"
                type="text"
                class="form-control"
                maxlength="50"
                style="text-transform:uppercase"
                autocomplete="off"
              />
            </div>
            <div class="col-md-4">
              <label for="cve_eje" class="form-label">Cve Ejecutor</label>
              <input
                id="cve_eje"
                v-model="filters.cve_eje"
                @keypress="validarCveEje"
                @keyup="buscarPorCve"
                type="text"
                class="form-control"
                maxlength="5"
                autocomplete="off"
              />
            </div>
          </div>
        </form>
      </div>
    </div>
    <div class="card">
      <div class="card-body p-0">
        <table class="table table-striped table-hover mb-0">
          <thead class="table-light">
            <tr>
              <th>Cve Ejecutor</th>
              <th>Nombre</th>
              <th>ID Rec</th>
              <th>RFC Inicial</th>
              <th>RFC Fecha</th>
              <th>RFC Homoclave</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="ejecutor in ejecutores" :key="ejecutor.id_ejecutor">
              <td>{{ ejecutor.cve_eje }}</td>
              <td>{{ ejecutor.nombre }}</td>
              <td>{{ ejecutor.id_rec }}</td>
              <td>{{ ejecutor.ini_rfc }}</td>
              <td>{{ ejecutor.fec_rfc ? formatDate(ejecutor.fec_rfc) : '' }}</td>
              <td>{{ ejecutor.hom_rfc }}</td>
            </tr>
            <tr v-if="ejecutores.length === 0">
              <td colspan="6" class="text-center">No se encontraron ejecutores</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div class="mt-3 text-end">
      <button class="btn btn-secondary" @click="cancelar">Cancelar</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EjecutoresPage',
  data() {
    return {
      ejecutores: [],
      filters: {
        nombre: '',
        cve_eje: ''
      },
      loading: false
    };
  },
  mounted() {
    this.cargarEjecutores();
  },
  methods: {
    cargarEjecutores() {
      this.loading = true;
      fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          eRequest: {
            action: 'listar',
            params: {}
          }
        })
      })
        .then(res => res.json())
        .then(json => {
          this.ejecutores = json.eResponse.data || [];
        })
        .finally(() => {
          this.loading = false;
        });
    },
    buscarPorNombre() {
      if (!this.filters.nombre) {
        this.cargarEjecutores();
        return;
      }
      fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          eRequest: {
            action: 'buscar_nombre',
            params: { nombre: this.filters.nombre }
          }
        })
      })
        .then(res => res.json())
        .then(json => {
          this.ejecutores = json.eResponse.data || [];
        });
    },
    buscarPorCve() {
      if (!this.filters.cve_eje) {
        this.cargarEjecutores();
        return;
      }
      fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          eRequest: {
            action: 'buscar_cve',
            params: { cve_eje: this.filters.cve_eje }
          }
        })
      })
        .then(res => res.json())
        .then(json => {
          this.ejecutores = json.eResponse.data || [];
        });
    },
    validarCveEje(e) {
      // Solo números, máximo 5 dígitos
      const char = String.fromCharCode(e.which);
      if (!/[0-9]/.test(char) && e.which > 31) {
        e.preventDefault();
      }
      if (this.filters.cve_eje.length >= 5 && e.target.selectionEnd === this.filters.cve_eje.length) {
        e.preventDefault();
      }
    },
    cancelar() {
      this.$router.back();
    },
    formatDate(dateStr) {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      return d.toLocaleDateString();
    }
  }
};
</script>

<style scoped>
.ejecutores-page {
  max-width: 900px;
  margin: 0 auto;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
}
</style>
