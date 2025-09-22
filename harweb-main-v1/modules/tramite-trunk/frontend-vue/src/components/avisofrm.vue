<template>
  <div class="aviso-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Aviso</li>
      </ol>
    </nav>
    <div class="card aviso-card" :style="{ width: '400px', margin: '0 auto', marginTop: '40px' }">
      <div class="card-body">
        <h5 class="card-title text-center mb-4" style="font-weight:bold;">{{ avisoLabel }}</h5>
        <div class="form-group form-check mb-3">
          <input type="checkbox" class="form-check-input" id="showMore" v-model="showMore" @change="onShowMoreChange">
          <label class="form-check-label" for="showMore">Más información</label>
        </div>
        <div v-if="showMore" class="form-group mb-3">
          <textarea class="form-control" rows="4" v-model="memoText" readonly></textarea>
        </div>
        <div class="text-end">
          <button class="btn btn-primary" @click="onAccept">Aceptar</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AvisoFormPage',
  data() {
    return {
      avisoLabel: '',
      memoText: '',
      showMore: false,
      userId: 1 // Simulated user id; replace with real user context if needed
    };
  },
  created() {
    this.fetchAvisoInfo();
  },
  methods: {
    fetchAvisoInfo() {
      // Call API to get aviso info
      this.$axios.post('/api/execute', {
        eRequest: {
          action: 'getAvisoInfo',
          params: {}
        }
      }).then(resp => {
        if (resp.data.eResponse.success) {
          this.avisoLabel = resp.data.eResponse.data.label;
          this.memoText = resp.data.eResponse.data.memo;
        } else {
          this.$toast.error('No se pudo cargar el aviso.');
        }
      }).catch(() => {
        this.$toast.error('Error de red al cargar el aviso.');
      });
    },
    onShowMoreChange() {
      // Optionally, you could fetch more info here
      // For now, memoText is already loaded
    },
    onAccept() {
      // Log the acknowledgement
      this.$axios.post('/api/execute', {
        eRequest: {
          action: 'logAvisoAcknowledgement',
          params: {
            user_id: this.userId,
            show_more: this.showMore,
            memo_text: this.showMore ? this.memoText : null
          }
        }
      }).then(resp => {
        if (resp.data.eResponse.success) {
          this.$toast.success('Aviso aceptado.');
          this.$router.push('/');
        } else {
          this.$toast.error('No se pudo registrar la aceptación.');
        }
      }).catch(() => {
        this.$toast.error('Error de red al aceptar el aviso.');
      });
    }
  }
};
</script>

<style scoped>
.aviso-card {
  min-height: 160px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}
.card-title {
  font-size: 1.1rem;
}
</style>
