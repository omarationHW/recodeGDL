<template>
  <div class="formabuscolonia-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Búsqueda de Colonias</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header text-center">
        <h5>BUSQUEDA DE COLONIAS</h5>
      </div>
      <div class="card-body">
        <form @submit.prevent>
          <div class="row align-items-center mb-3">
            <div class="col-md-3 text-end">
              <label for="coloniaInput" class="form-label">Nombre de la colonia</label>
            </div>
            <div class="col-md-6">
              <input
                id="coloniaInput"
                v-model="filtro"
                @input="buscarColonias"
                type="text"
                class="form-control text-uppercase"
                placeholder="Ingrese el nombre de la colonia"
                autocomplete="off"
                autofocus
              />
            </div>
          </div>
        </form>
        <div class="table-responsive mb-3">
          <table class="table table-bordered table-hover">
            <thead class="table-light">
              <tr>
                <th>Colonia/Asentamiento</th>
                <th>Código Postal</th>
                <th>Tipo Asentamiento</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(col, idx) in colonias" :key="idx" @click="seleccionarColonia(col)" :class="{ 'table-active': seleccionada && seleccionada.colonia === col.colonia }" style="cursor:pointer;">
                <td>{{ col.colonia }}</td>
                <td>{{ col.d_codigopostal }}</td>
                <td>{{ col.d_tipo_asenta }}</td>
              </tr>
              <tr v-if="colonias.length === 0">
                <td colspan="3" class="text-center">No se encontraron colonias</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="d-flex justify-content-end">
          <button class="btn btn-primary" @click="aceptar" :disabled="!seleccionada">Aceptar</button>
        </div>
        <div v-if="resultado" class="mt-3 alert alert-success">
          <strong>Colonia seleccionada:</strong> {{ resultado.colonia }}<br>
          <strong>Código Postal:</strong> {{ resultado.d_codigopostal }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'FormabuscoloniaPage',
  data() {
    return {
      filtro: '',
      colonias: [],
      seleccionada: null,
      resultado: null,
      loading: false
    };
  },
  mounted() {
    this.buscarColonias();
  },
  methods: {
    async buscarColonias() {
      this.loading = true;
      this.seleccionada = null;
      this.resultado = null;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'buscar_colonias',
            params: { filtro: this.filtro }
          })
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success) {
          this.colonias = data.eResponse.data;
        } else {
          this.colonias = [];
        }
      } catch (e) {
        this.colonias = [];
      } finally {
        this.loading = false;
      }
    },
    seleccionarColonia(col) {
      this.seleccionada = col;
    },
    async aceptar() {
      if (!this.seleccionada) return;
      // Obtener datos completos de la colonia seleccionada
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'obtener_colonia_seleccionada',
            params: { colonia: this.seleccionada.colonia }
          })
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success && data.eResponse.data.length > 0) {
          this.resultado = data.eResponse.data[0];
        } else {
          this.resultado = null;
        }
      } catch (e) {
        this.resultado = null;
      }
    }
  }
};
</script>

<style scoped>
.formabuscolonia-page {
  max-width: 800px;
  margin: 0 auto;
  padding-top: 30px;
}
.table-active {
  background-color: #e9ecef !important;
}
.text-uppercase {
  text-transform: uppercase;
}
</style>
