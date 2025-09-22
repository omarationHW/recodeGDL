<template>
  <div class="busqueda-scian-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Búsqueda de giros</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header text-center">
        <h5>BUSQUEDA DE GIROS</h5>
      </div>
      <div class="card-body">
        <form @submit.prevent>
          <div class="form-group row">
            <label for="descripcion" class="col-sm-2 col-form-label">Descripción del giro</label>
            <div class="col-sm-10">
              <input
                id="descripcion"
                v-model="descripcion"
                @input="buscar"
                type="text"
                class="form-control"
                placeholder="Ingrese descripción o código SCIAN"
                style="text-transform:uppercase"
                maxlength="200"
                autocomplete="off"
              />
            </div>
          </div>
        </form>
        <div class="table-responsive mt-3">
          <table class="table table-bordered table-hover table-sm">
            <thead class="thead-light">
              <tr>
                <th style="width: 80px;">SCIAN</th>
                <th>Descripción</th>
                <th style="width: 60px;">Tipo</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in resultados" :key="row.codigo_scian" @click="seleccionar(row)" :class="{'table-active': row.codigo_scian === seleccionado?.codigo_scian}" style="cursor:pointer">
                <td>{{ row.codigo_scian }}</td>
                <td>{{ row.descripcion }}</td>
                <td>{{ row.tipo }}</td>
              </tr>
              <tr v-if="resultados.length === 0">
                <td colspan="3" class="text-center">No se encontraron resultados.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="card-footer text-center">
        <button class="btn btn-primary" :disabled="!seleccionado" @click="aceptar">Aceptar</button>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'BusquedaScianPage',
  data() {
    return {
      descripcion: '',
      resultados: [],
      seleccionado: null,
      error: null
    };
  },
  mounted() {
    this.buscar();
  },
  methods: {
    buscar() {
      this.error = null;
      fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: JSON.stringify({
          eRequest: 'catalog.scian.search',
          params: { descripcion: this.descripcion }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.success) {
            this.resultados = json.data;
            // Si la búsqueda cambia, deselecciona
            this.seleccionado = null;
          } else {
            this.error = json.error || 'Error al buscar.';
            this.resultados = [];
          }
        })
        .catch(err => {
          this.error = err.message || 'Error de red.';
          this.resultados = [];
        });
    },
    seleccionar(row) {
      this.seleccionado = row;
    },
    aceptar() {
      if (this.seleccionado) {
        // Aquí puedes emitir un evento, redirigir, o guardar la selección
        // Por ejemplo, emitir evento:
        this.$emit('scian-selected', this.seleccionado);
        // O mostrar un mensaje
        alert(`SCIAN seleccionado: ${this.seleccionado.codigo_scian} - ${this.seleccionado.descripcion}`);
      }
    }
  }
};
</script>

<style scoped>
.busqueda-scian-page {
  max-width: 950px;
  margin: 0 auto;
  padding: 30px 0;
}
.table-hover tbody tr:hover {
  background-color: #f5f5f5;
}
.table-active {
  background-color: #d1ecf1 !important;
}
</style>
