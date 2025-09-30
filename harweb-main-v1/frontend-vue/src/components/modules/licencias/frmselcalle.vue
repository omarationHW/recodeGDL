<template>
  <div class="frmselcalle-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Selección de Calle</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header">
        <h5>Calle:</h5>
      </div>
      <div class="card-body">
        <div class="mb-3">
          <input
            v-model="filter"
            @input="onFilterChange"
            class="form-control"
            type="text"
            placeholder="Buscar calle..."
            style="text-transform:uppercase"
            maxlength="100"
            autofocus
          />
        </div>
        <div style="max-height: 300px; overflow-y: auto;">
          <table class="table table-hover table-bordered">
            <thead>
              <tr>
                <th style="width: 40px;"></th>
                <th>Calle</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(row, idx) in calles" :key="row.cvecalle">
                <td>
                  <input
                    type="checkbox"
                    :value="row.cvecalle"
                    v-model="selectedRows"
                  />
                </td>
                <td>{{ row.calle }}</td>
              </tr>
              <tr v-if="calles.length === 0">
                <td colspan="2" class="text-center">No hay resultados</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="card-footer d-flex justify-content-between align-items-center">
        <div>
          <span v-if="selectedRows.length > 0">
            Seleccionados: {{ selectedRows.join(',') }}
          </span>
          <span v-else>
            Seleccionados: 0
          </span>
        </div>
        <button class="btn btn-primary" @click="onAccept">Aceptar</button>
      </div>
    </div>
    <div v-if="showResult" class="alert alert-success mt-3">
      <strong>IDs seleccionados:</strong> {{ selectedRows.join(',') }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'FrmSelCalle',
  data() {
    return {
      filter: '',
      calles: [],
      selectedRows: [],
      showResult: false
    };
  },
  mounted() {
    this.fetchCalles();
  },
  methods: {
    fetchCalles() {
      const payload = {
        eRequest: 'get_calles',
        eParams: { filter: this.filter.trim() }
      };
      fetch('http://localhost:8000/api/generic', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify(payload)
      })
        .then(res => res.json())
        .then(json => {
          if (json.eResponse && json.eResponse.success) {
            this.calles = json.eResponse.data;
          } else {
            this.calles = [];
          }
        })
        .catch(() => {
          this.calles = [];
        });
    },
    onFilterChange() {
      this.filter = this.filter.toUpperCase();
      this.fetchCalles();
    },
    onAccept() {
      this.showResult = true;
      // Optionally, emit or route with selectedRows
      // this.$emit('selected', this.selectedRows);
    }
  }
};
</script>

<style scoped>
.frmselcalle-page {
  max-width: 500px;
  margin: 40px auto;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.table th, .table td {
  vertical-align: middle;
}
</style>
