<template>
  <div class="consulta-sandres-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta Cementerio San Andrés</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">Consultas a la base de Datos de Cementerio San Andrés</h5>
        <button class="btn btn-secondary" @click="goBack">Salir</button>
      </div>
      <div class="card-body">
        <div v-if="loading" class="text-center my-5">
          <span class="spinner-border" role="status"></span> Cargando datos...
        </div>
        <div v-else>
          <div class="table-responsive">
            <table class="table table-striped table-bordered table-hover">
              <thead>
                <tr>
                  <th v-for="col in columns" :key="col">{{ col }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in rows" :key="row.id || row[columns[0]]">
                  <td v-for="col in columns" :key="col">{{ row[col] }}</td>
                </tr>
              </tbody>
            </table>
          </div>
          <nav v-if="pagination.total > pagination.per_page" class="mt-3">
            <ul class="pagination justify-content-center">
              <li class="page-item" :class="{disabled: pagination.page === 1}">
                <button class="page-link" @click="changePage(pagination.page - 1)">Anterior</button>
              </li>
              <li class="page-item" v-for="p in totalPages" :key="p" :class="{active: p === pagination.page}">
                <button class="page-link" @click="changePage(p)">{{ p }}</button>
              </li>
              <li class="page-item" :class="{disabled: pagination.page === totalPages}">
                <button class="page-link" @click="changePage(pagination.page + 1)">Siguiente</button>
              </li>
            </ul>
          </nav>
        </div>
        <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsultaSAndres',
  data() {
    return {
      loading: false,
      error: '',
      columns: [],
      rows: [],
      pagination: {
        page: 1,
        per_page: 20,
        total: 0
      }
    };
  },
  computed: {
    totalPages() {
      return Math.ceil(this.pagination.total / this.pagination.per_page);
    }
  },
  methods: {
    fetchData(page = 1) {
      this.loading = true;
      this.error = '';
      fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          action: 'consultar_sanandres_paginated',
          params: {
            page: page,
            per_page: this.pagination.per_page
          }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.success) {
            this.rows = json.data.items;
            this.pagination.page = json.data.page;
            this.pagination.per_page = json.data.per_page;
            this.pagination.total = json.data.total;
            this.columns = this.rows.length > 0 ? Object.keys(this.rows[0]) : [];
          } else {
            this.error = json.message || 'Error al consultar los datos.';
          }
        })
        .catch(err => {
          this.error = err.message || 'Error de red.';
        })
        .finally(() => {
          this.loading = false;
        });
    },
    changePage(p) {
      if (p < 1 || p > this.totalPages) return;
      this.fetchData(p);
    },
    goBack() {
      this.$router.back();
    }
  },
  mounted() {
    this.fetchData(1);
  }
};
</script>

<style scoped>
.consulta-sandres-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 0;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}
.table th, .table td {
  font-size: 0.95rem;
}
</style>
