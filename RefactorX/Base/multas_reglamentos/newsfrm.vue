<template>
  <div class="newsfrm-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Cambios del Módulo</li>
      </ol>
    </nav>
    <div class="card shadow">
      <div class="card-header bg-primary text-white">
        <h4 class="mb-0">Cambios realizados al módulo</h4>
      </div>
      <div class="card-body">
        <div v-if="loading" class="text-center my-5">
          <span class="spinner-border"></span>
          <span class="ms-2">Cargando...</span>
        </div>
        <div v-else>
          <div class="alert alert-info" v-if="changes && changes.length">
            <ul class="list-unstyled mb-0">
              <li v-for="(change, idx) in changes" :key="idx">
                <pre class="mb-2">{{ change.change_text }}</pre>
              </li>
            </ul>
          </div>
          <div v-else class="alert alert-warning">
            No hay cambios registrados.
          </div>
          <button class="btn btn-success mt-3" @click="acknowledge" :disabled="acknowledged">
            {{ acknowledged ? 'Cambios Aceptados' : 'Aceptar Cambios' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'NewsFrmPage',
  data() {
    return {
      loading: true,
      changes: [],
      acknowledged: false
    };
  },
  methods: {
    fetchChanges() {
      this.loading = true;
      this.$axios.post('/api/execute', {
        eRequest: 'get_news_changes',
        params: {}
      })
      .then(res => {
        this.changes = res.data.eResponse.data || [];
      })
      .catch(() => {
        this.changes = [];
      })
      .finally(() => {
        this.loading = false;
      });
    },
    acknowledge() {
      // Simulación: en app real, usar auth para user_id
      const user_id = this.$store?.state?.auth?.user?.id || 1;
      this.$axios.post('/api/execute', {
        eRequest: 'acknowledge_news_changes',
        params: { user_id }
      })
      .then(() => {
        this.acknowledged = true;
      });
    }
  },
  mounted() {
    this.fetchChanges();
  }
};
</script>

<style scoped>
.newsfrm-page {
  max-width: 700px;
  margin: 40px auto;
}
pre {
  background: #f8f9fa;
  padding: 10px;
  border-radius: 4px;
  font-family: 'Consolas', 'Menlo', monospace;
}
</style>
